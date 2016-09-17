module Module::City::Initializer

  def init_hash(params)

    #params[:city_has_roles_attributes] = params[:city_has_roles]
    #params[:city_has_roles_attributes].each { |city_has_role_attributes|
    #  city_has_role_attributes[:role_id] = city_has_role_attributes[:role][:id]
    #}
    #
    #params[:city][:residents_attributes] = params[:city][:residents]
    #params[:city][:self_generated_result_types_attributes] = params[:city][:self_generated_result_types]
    #params[:city][:game_end_conditions_attributes] = params[:city][:game_end_conditions]
    # params[:city][:day_cycles_attributes] = params[:city][:day_cycles]

    params.require(:name)
    params.require(:timezone)
    cleaned_params = params.permit(:name, :timezone, :description, :public)


    #cleaned_params.delete(:id)
    #cleaned_params.delete(:current_day)
    #cleaned_params.delete(:last_paused_at)
    #cleaned_params.delete(:days)

    cleaned_params[:city_has_roles] = []
    unless params[:city_has_roles].nil?
      params[:city_has_roles].each { |city_has_role_params|
        city_has_role_hash = city_has_role_params.permit(:id).tap {|chr| chr[:action_types_params] = city_has_role_params[:action_types_params]}
        city_has_role = nil

        if city_has_role_hash[:id].nil?
          city_has_role = CityHasRole.new(city_has_role_hash)
          city_has_role.role_id = city_has_role_params.require(:role).require(:id)
        else
          city_has_role = CityHasRole.find(city_has_role_params.require(:id))
          city_has_role_hash.delete(:id)
          city_has_role.update_attributes(city_has_role_hash)
        end
        cleaned_params[:city_has_roles] << city_has_role
      }
    end

    cleaned_params[:residents] = []
    unless params[:residents].nil?
      params[:residents].each { |resident_params|
        resident_hash = resident_params.permit(:id, :user_id) # Module::ParameterPruning.prune_parameters_for_model(resident_params, Resident.new())
        resident = nil
        if resident_hash[:id].nil?
          resident = Resident.new(resident_hash)
        else
          resident = Resident.find(resident_hash[:id])
          resident_hash.delete(:id)
          # resident.update_attributes(resident_hash)
        end
        cleaned_params[:residents] << resident
      }
    end


    cleaned_params[:self_generated_result_types] = []
    params.require(:self_generated_result_types).each { |self_generated_result_type_params|
      self_generated_result_type_hash = self_generated_result_type_params.permit(:id) # Module::ParameterPruning.prune_parameters_for_model(self_generated_result_type_params, ActionResultType.new())
      self_generated_result_type = nil
      if self_generated_result_type_hash[:id].nil?
        # self_generated_result_type = ActionResultType.new(self_generated_result_type_hash)
      else
        self_generated_result_type = ActionResultType.find(self_generated_result_type_hash[:id])
        # self_generated_result_type_hash.delete(:id)
        # self_generated_result_type.update_attributes(self_generated_result_type_hash)

        cleaned_params[:self_generated_result_types] << self_generated_result_type
      end

    }

    cleaned_params[:game_end_conditions] = []
    params.require(:game_end_conditions).each { |game_end_condition_params|
      game_end_condition_hash = game_end_condition_params.permit(:id) # Module::ParameterPruning.prune_parameters_for_model(game_end_condition_params, GameEndCondition.new())
      game_end_condition = nil
      if game_end_condition_hash[:id].nil?
        # game_end_condition = GameEndCondition.new(game_end_condition_hash)
      else
        game_end_condition = GameEndCondition.find(game_end_condition_hash[:id])
        # game_end_condition_hash.delete(:id)
        # game_end_condition.update_attributes(game_end_condition_hash)
        cleaned_params[:game_end_conditions] << game_end_condition
      end

    }

    cleaned_params[:day_cycles] = []
    params.require(:day_cycles).each { |day_cycle_params|
      day_cycle_hash = day_cycle_params.permit(:id, :day_start, :night_start) # Module::ParameterPruning.prune_parameters_for_model(day_cycle_params, DayCycle.new())
      day_cycle = nil
      if day_cycle_hash[:id].nil?
        day_cycle = DayCycle.new(day_cycle_hash)
      else
        day_cycle = DayCycle.find(day_cycle_hash[:id])
        day_cycle_hash.delete(:id)
        day_cycle.update_attributes(day_cycle_hash)
      end
      cleaned_params[:day_cycles] << day_cycle
    }


    if params[:password] && params[:password].length > 0
      cleaned_params[:password] = params[:password]
      cleaned_params[:password_salt] = Time.now.to_i().to_s()
      generated_hashed_password = Static::PasswordUtility.generate_hashed_password(params[:password], cleaned_params[:password_salt])
      cleaned_params[:hashed_password] = generated_hashed_password
    end


    cleaned_params
  end



  def ping_all_cities
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    cities = self.where('cities.started_at IS NOT NULL').where('cities.finished_at IS NULL').where(:paused => false).all
    logger.info("MANUAL LOG - running cities count: #{cities.count}")
    scheduler = AppConfig.instance.scheduler

    cities.each { |city|
      city_jobs = scheduler.jobs(:tag => city.scheduler_tag())
      if city_jobs.empty?
        city.start_day_cycle_handlers()
        logger.info("MANUAL LOG - #{city.name}:#{city.id} day cycles re-scheduled.")
      else
        logger.info("MANUAL LOG - #{city.name}:#{city.id} day cycles already scheduled.")
      end
    }

  end

  def destroy_inactive_cities
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())
    cities = self.where('cities.last_accessed_at <= ?', 3.day.ago.to_datetime())
    logger.info("MANUAL LOG - destroying cities count: #{cities.count}")
    destroyed = cities.destroy_all()
    logger.info("MANUAL LOG - destroyed cities count: #{destroyed.length}")
  end

end