class ActionType::Protect < ActionType

  KEY_TARGET_ID = "target_id"

  def before_creation
    super
    self.trigger_id = Trigger::DAY_START
    self.require_alive_processing = true # resident must be alive at the time an action of this type comes to processing, otherwise: action is void
    self.name = 'Protect'
    self.action_result_type_id = ActionResultType::PROTECT
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

    self.process_actions(actions)
  end

  def create_void_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    self.process_actions(actions)
  end

  protected

  def process_actions(actions)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end

    logger.info('MANUAL LOG - action not empty')

    actions_per_resident = Action.latest_action_per_resident(actions)

    logger.info('MANUAL LOG - actions per resident')

    action_results = []
    actions_per_resident.each_pair { |resident, action|

      logger.info('MANUAL LOG - processing action performed by resident ' + resident.id.to_s())

      target_id = action.input[KEY_TARGET_ID]
      if target_id == resident.id
        # doctor cannot protect himself
        # target_id = -1
        next
      end
      action_results << {:action => action,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => resident.city_id,
                         :resident_id => resident.id,
                         :role_id => action.role_id,
                         # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                         :result => {self.action_result_type.class::KEY_TARGET_ID => target_id, self.action_result_type.class::KEY_SUCCESS => false},
                         :is_automatically_generated => true}
    }


    logger.info('MANUAL LOG - returning action results')

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