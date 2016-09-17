class ActionResolver::JournalistInvestigateSelfGeneratedActionTypeParams < ActionResolver
  # for decreasing number of remaining actions in ResidentsRoleActionTypeParams

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # journalist_investigate vs. self generated action type params

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    self_generated_action_type_params_per_resident_id = {}

    unless valid_results_hash[ActionResultType::JournalistInvestigate].nil?

      valid_results_hash[ActionResultType::SelfGenerated::ActionTypeParams].each { |self_generated_action_type_params_result_hash|
        self_generated_action_type_params_per_resident_id[self_generated_action_type_params_result_hash[:resident_id]] = self_generated_action_type_params_result_hash
      }

      decrease_available_actions(valid_results_hash, self_generated_action_type_params_per_resident_id)

    end

    unless void_results_hash[ActionResultType::JournalistInvestigate].nil?
      if self_generated_action_type_params_per_resident_id.empty?
        valid_results_hash[ActionResultType::SelfGenerated::ActionTypeParams].each { |self_generated_action_type_params_result_hash|
          self_generated_action_type_params_per_resident_id[self_generated_action_type_params_result_hash[:resident_id]] = self_generated_action_type_params_result_hash
        }
      end

      decrease_available_actions(void_results_hash, self_generated_action_type_params_per_resident_id)

    end

    # / journalist_investigate vs. self generated action type params
  end

  def decrease_available_actions(results_hashes, self_generated_action_type_params_per_resident_id)
    results_hashes[ActionResultType::JournalistInvestigate].each { |result_hash|
      unless result_hash[:is_automatically_generated]
        next
      end

      action = result_hash[:action]
      if action.nil?
        next
      end

      self.modify_action_type_params(action)

      resident_id = action.resident_id
      role_id_string = action.role_id.to_s()
      action_type_id_string = ActionType::JOURNALIST.to_s()

      journalist_investigate_action_type_params_hash = self_generated_action_type_params_per_resident_id[resident_id][:result][ActionResultType::SelfGenerated::ActionTypeParams::KEY_ACTION_TYPES_PARAMS][role_id_string][action_type_id_string]
      if journalist_investigate_action_type_params_hash[ActionType::JournalistInvestigate::PARAM_LIFETIME_ACTIONS_COUNT]>0
        journalist_investigate_action_type_params_hash[ActionType::JournalistInvestigate::PARAM_LIFETIME_ACTIONS_COUNT] -= 1
      else
        # counter is already at -1, so this action is infinitely available for this resident
      end
    }

  end

  def modify_action_type_params(action)
    if action.action_type_params.action_type_params_hash[ActionType::JournalistInvestigate::PARAM_LIFETIME_ACTIONS_COUNT] > 0
      action.action_type_params.action_type_params_hash[ActionType::JournalistInvestigate::PARAM_LIFETIME_ACTIONS_COUNT] -= 1
      action.action_type_params.save()
    end
  end

  def set_ordinal
    self.ordinal = 1570
  end

end