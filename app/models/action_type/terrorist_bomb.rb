class ActionType::TerroristBomb < ActionType

  KEY_TARGET_ID = :target_id

  PARAM_DETONATION_DELAY = 'detonation_delay'
  PARAM_NUMBER_OF_COLLATERALS = 'number_of_collaterals'

  def before_creation
    super
    self.trigger_id = Trigger::ASYNC
    @default_params = action_type_params()
    self.default_params_json = self.default_params.to_json()

    self.name = 'Bomb'
    self.action_result_type_id = ActionResultType::TERRORIST_BOMB
  end

  def action_type_params
    {
        PARAM_DETONATION_DELAY => '5m',
        PARAM_NUMBER_OF_COLLATERALS => 1 # how many residents will die in addition to the target resident and the terrorist
    }
  end

  def params_valid(action_type_params)
    if action_type_params.nil?
      return true
    end

    detonation_delay_correct_format = /^[1-9]\d*[smh]$/.match(action_type_params[PARAM_DETONATION_DELAY])
    number_of_collaterals_is_numeric = action_type_params[PARAM_NUMBER_OF_COLLATERALS].is_a?(Numeric)
    detonation_delay_correct_format && number_of_collaterals_is_numeric
  end

  def action_valid?(action, action_type_params_per_resident_role_action_type)
    unless super
      return false
    end

    mafia_residents = action.city.residents.joins('LEFT JOIN roles ON residents.role_id = roles.id').where('roles.affiliation_id = ?', Affiliation::MAFIA)

    mafia_members_result = action.resident.action_results.where(:action_result_type_id => ActionResultType::MAFIA_MEMBERS).order('action_results.id DESC').first()
    if mafia_members_result.nil?
      return false
    end

    mafia_resident_ids_from_result = mafia_members_result.result[ActionResultType::SingleRequired::MafiaMembers::KEY_MAFIA_MEMBERS]
    mafia_resident_ids = mafia_residents.map do |r|
      r.id
    end

    is_result_correct = mafia_resident_ids_from_result.sort == mafia_resident_ids.sort
    if is_result_correct
      logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s() + ': mafia members list authentic.')
    else
      logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s() + ': mafia members reported ' + mafia_resident_ids_from_result.to_s() + '; true mafia members ' + mafia_resident_ids.to_s())
    end

    is_result_correct
  end


  def create_valid_action_results(actions, city)
    # actions are async
  end

  def create_void_action_results(actions, city)
    # actions are async
  end

  def start_valid_async_execution(action)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    previous_actions = Action.includes(:resident).where(:action_type_id => action.action_type_id).where('actions.resident_id' => action.resident_id).where('actions.is_processed' => false).where('actions.id != ?', action.id)
    previous_actions.each { |previous_action|
      previous_action.stop_async_action
    }
    previous_actions.update_all(:is_processed => true)

    if action.input[KEY_TARGET_ID] != -1
      schedule_detonation(action)
    end
  end

  def start_void_async_execution(action)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    action.update(:is_processed => true)
    # do nothing
    # do not schedule detonation because action is void
  end

  # @param [Action] action
  def schedule_detonation(action)
    scheduler = AppConfig.instance.scheduler
    params = action.action_type_params(false).action_type_params_hash
    job = scheduler.schedule_in(params[PARAM_DETONATION_DELAY], :tag => action.scheduler_tag) {

      self.detonate_action(action)
    }

  end


  def detonate_action(action)
    if action.action_type_id != ActionType::TERRORIST_BOMB
      return
    end

    params = action.action_type_params(false).action_type_params_hash

    target_id = action.input[KEY_TARGET_ID]
    target_ids = [target_id]
    if target_id != action.resident_id
      target_ids << action.resident_id
    end

    city_residents = action.city.residents

    alive_residents = city_residents.select { |resident| resident.alive }
    alive_residents.delete_if { |resident| (resident.id == action.resident.id || resident.id == target_id) }

    params[PARAM_NUMBER_OF_COLLATERALS].times {
      if alive_residents.length > 1
        random_resident = alive_residents.delete_at(rand(alive_residents.length))
        target_ids << random_resident.id
      end
    }

    target_ids = target_ids.permutation().to_a().sample()

    valid_results_hash_array = []
    #city_residents.each { |resident|
    valid_results_hash_array << {:action => action,
                                 :action_result_type_id => self.action_result_type_id,
                                 :city_id => action.resident.city_id,
                                 :resident_id => nil, # terrorist bomb result will be visible to all residents
                                 :role_id => nil,
                                 # no need to set :day property, it is being set few lines below using Module::ActionResult::StoreResults
                                 :result => {self.action_result_type.class::KEY_TARGET_IDS => target_ids, self.action_result_type.class::KEY_SUCCESS => true},
                                 :is_automatically_generated => true}
    #}


    valid_results_hash = {self.action_result_type.class => valid_results_hash_array}

    valid_results_hash.merge!(action.city.self_generated_results(action.city.current_day(true), Trigger::BOTH, [ActionResultType::SelfGenerated::Residents]))

    ::ActionResolver.resolve_action_results(valid_results_hash, {}, action.city, Trigger::ASYNC)

    ActiveRecord::Base.transaction {
      # self.action_result_class.implement(valid_results_hash_array)

      Static::ActionResult::StoreResults.store_results(valid_results_hash, action.city.current_day(true)) # method declared in Module::StoreResults

      action.is_processed = true
      action.save()
    }
  end



  def stop_valid_async_execution(action)
    self.unschedule_detonation(action)
  end

  def stop_void_async_execution(action)
    # nothing to do here, detonation was not even scheduled
  end

  # @param [Action] action
  def unschedule_detonation(action)
    scheduler = AppConfig.instance.scheduler
    jobs = scheduler.jobs(:tag => action.scheduler_tag)
    jobs.each { |job|
      job.unschedule()
    }
  end


end