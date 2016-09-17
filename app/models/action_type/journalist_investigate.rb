class ActionType::JournalistInvestigate < ActionType

  KEY_TARGET_ID = "target_id"

  def before_creation
    super
    self.trigger_id = Trigger::DAY_START
    self.require_alive_processing = true # resident must be alive at the time an action of this type comes to processing, otherwise: action is void
    self.name = 'Journalist Investigate'
    self.action_result_type_id = ActionResultType::JOURNALIST
  end

  PARAM_LIFETIME_ACTIONS_COUNT = 'number_of_actions_available'

  def action_type_params
    {
        PARAM_LIFETIME_ACTIONS_COUNT => -1 # infinite
    }
  end

  def params_valid(action_type_params)
    if action_type_params.nil?
      return true
    end

    actions_count_param = action_type_params[PARAM_LIFETIME_ACTIONS_COUNT]
    actions_count_param.is_a?(Numeric)
  end


  def action_valid?(action, action_type_params_per_resident_role_action_type)
    actions_available(action, action_type_params_per_resident_role_action_type)
  end



  def create_valid_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end

    actions_per_resident = Action.latest_action_per_resident(actions)

    action_results = []
    actions_per_resident.each_pair { |resident, action|

      target_id = action.input[KEY_TARGET_ID]

      action_results << {:action => action,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => resident.city_id,
                         :resident_id => resident.id,
                         :role_id => action.role_id,
                         # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                         :result => {self.action_result_type.class::KEY_TARGET_ID => target_id, self.action_result_type.class::KEY_SUCCESS => false},
                         :is_automatically_generated => true}
    }

    action_results #return array of ActionResult init hashes
  end

  def create_void_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end

    actions_per_resident = Action.latest_action_per_resident(actions)

    action_results = []
    actions_per_resident.each_pair { |resident, action|

      target_id = action.input[KEY_TARGET_ID]

      alive_mafia = city.residents.select{ |r| r.alive && r.role.affiliation_id == Affiliation::MAFIA }
      resident_pool = city.residents.select{ |r| r.alive && r.role.affiliation_id != Affiliation::MAFIA }
      sample_resident = resident_pool.concat(alive_mafia.sample((alive_mafia.count-1)/2 + 1)).sample
      success = sample_resident.role.affiliation_id == Affiliation::MAFIA
      # void action that has been performed before? it should produce the same result!
      previous_action_result = ActionResult.joins('LEFT JOIN actions ON action_results.action_id = actions.id').where('actions.resident_id' => action.resident_id).where('actions.action_type_id' => action.action_type_id).where('actions.role_id' => action.role_id).where('actions.input_json' => {KEY_TARGET_ID => target_id}.to_json).order('action_results.id DESC').first
      if previous_action_result
        success = previous_action_result.result[self.action_result_type.class::KEY_SUCCESS]
      end
      action_results << {:action => action,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => resident.city_id,
                         :resident_id => resident.id,
                         :role_id => action.role_id,
                         :result => {self.action_result_type.class::KEY_TARGET_ID => target_id, self.action_result_type.class::KEY_SUCCESS => success},
                         :is_automatically_generated => true}
    }

    action_results #return array of ActionResult init hashes
  end


  private

  def actions_available(action, action_type_params_per_resident_role_action_type)
    resident_role_action_type_params = nil
    if action_type_params_per_resident_role_action_type[action.resident_id].nil? ||
        action_type_params_per_resident_role_action_type[action.resident_id][action.role_id].nil? ||
        action_type_params_per_resident_role_action_type[action.resident_id][action.role_id][action.action_type_id].nil?
      resident_role_action_type_params = ResidentRoleActionTypeParamsModel.create(:resident_id => action.resident_id, :role_id => action.role_id, :action_type_id => action.action_type_id)
    else
      resident_role_action_type_params = action_type_params_per_resident_role_action_type[action.resident_id][action.role_id][action.action_type_id]
    end


    if resident_role_action_type_params.action_type_params_hash[PARAM_LIFETIME_ACTIONS_COUNT] < 0
      return true # negative value interpreted as infinite
    end

    actions_available = resident_role_action_type_params.action_type_params_hash[PARAM_LIFETIME_ACTIONS_COUNT] > 0
    actions_available
  end

end