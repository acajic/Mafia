class ActionType::SingleRequired::Residents < ActionType

  def before_creation
    super
    self.trigger_id = Trigger::NO_TRIGGER
    self.is_single_required = true
    self.action_result_type_id = ActionResultType::RESIDENTS
    self.name = 'Residents'
  end

  def single_required_action_initializer(resident, role_id, action_results)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    should_create_action_result = false

    if action_results.nil? || action_results.empty?
      should_create_action_result = true
    end


    if should_create_action_result
      return {:resident_id => resident ? resident.id : nil, :role_id => role_id, :action_type_id => self.id, :day => nil, :input_json => nil, :is_processed => true}
    else
      return nil
    end


  end

  def create_valid_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end

    action = actions[0]
    self.action_result_type.class.self_generated_results(city, nil, nil).map { |action_result_hash|
      action_result_hash[:action] = action
      action_result_hash
    }
  end

  def create_void_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end

    create_valid_action_results(actions, city)
  end

end