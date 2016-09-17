class ActionResolver::SheriffSelfGeneratedResidents < ActionResolver
  # if a sheriff died, assign a random citizen to become new sheriff

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless valid_results_hash[ActionResultType::SelfGenerated::Residents].nil?
      # first SelfGenerated::Residents result

      gsr_result = valid_results_hash[ActionResultType::SelfGenerated::Residents][0]

      alive_residents = city.residents.where(:alive => true).to_a()
      current_sheriff_count = alive_residents.select { |resident| resident.role_id == Role::SHERIFF }.length()
      city_has_roles_sheriff = city.city_has_roles.where(:role_id => Role::SHERIFF)
      orig_sheriff_count = city_has_roles_sheriff.count
      if current_sheriff_count < orig_sheriff_count
        new_sheriff_count = orig_sheriff_count - current_sheriff_count
        alive_citizens = alive_residents.select { |resident| resident.role_id == Role::CITIZEN }
        if alive_citizens.length() > 0
          new_sheriff_count = [new_sheriff_count, alive_citizens.length()].min()
          new_sheriffs = alive_citizens.sample(new_sheriff_count)
          new_sheriffs.each { |resident|
            ResidentPreviousRole.create(:resident_id => resident.id, :previous_role_id => resident.role_id, :day_id => gsr_result[:day_id])
            resident.role_id = Role::SHERIFF
            resident.saved_role_id = Role::SHERIFF
            resident.save()

            resident_role_action_type_params_model = ResidentRoleActionTypeParamsModel.where(:resident_id => resident.id, :role_id => Role::SHERIFF, :action_type_id => ActionType::SHERIFF_IDENTITIES).first()
            if resident_role_action_type_params_model
              resident_role_action_type_params_model.reset_action_type_params()
            end

            if valid_results_hash[ActionResultType::ResidentBecameSheriff].nil?
              valid_results_hash[ActionResultType::ResidentBecameSheriff] = []
            end
            valid_results_hash[ActionResultType::ResidentBecameSheriff] << {:action => nil,
                                                                        :action_result_type_id => ActionResultType::RESIDENT_BECAME_SHERIFF,
                                                                        :city_id => resident.city_id,
                                                                        :resident_id => resident.id,
                                                                        :role_id => nil,
                                                                        # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                                                                        :result => nil,
                                                                        :is_automatically_generated => true}
          }
        end
      end

    end
  end

  def set_ordinal
    self.ordinal = 1600
  end
end