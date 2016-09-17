class ActionResolver::TellerVotesSelfGeneratedActionTypeParams < ActionResolver
  # for decreasing number of remaining actions in ResidentsRoleActionTypeParams

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # teller votes vs. self generated action type params

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    self_generated_action_type_params_per_resident_id = {}
    unless valid_results_hash[ActionResultType::TellerVotes].nil? || valid_results_hash[ActionResultType::SelfGenerated::ActionTypeParams].nil?

      valid_results_hash[ActionResultType::SelfGenerated::ActionTypeParams].each { |self_generated_action_type_params_result_hash|
        self_generated_action_type_params_per_resident_id[self_generated_action_type_params_result_hash[:resident_id]] = self_generated_action_type_params_result_hash
      }

      decrease_available_actions(valid_results_hash, self_generated_action_type_params_per_resident_id)

    end

    unless void_results_hash[ActionResultType::TellerVotes].nil?
      if self_generated_action_type_params_per_resident_id.empty?

        valid_results_hash[ActionResultType::SelfGenerated::ActionTypeParams].each { |self_generated_action_type_params_result_hash|
          self_generated_action_type_params_per_resident_id[self_generated_action_type_params_result_hash[:resident_id]] = self_generated_action_type_params_result_hash
        }
      end

      decrease_available_actions(void_results_hash, self_generated_action_type_params_per_resident_id)

    end

    # / teller votes vs. self generated action type params
  end

  def decrease_available_actions(results_hashes, self_generated_action_type_params_per_resident_id)
    results_hashes[ActionResultType::TellerVotes].each { |result_hash|
      unless result_hash[:result][ActionResultType::TellerVotes::KEY_SUCCESS]
        next
      end

      resident_id = result_hash[:resident_id]
      role_id_string = result_hash[:role_id].to_s()
      action_type_id_string = ActionType::TELLER_VOTES.to_s()

      self.modify_action_type_params(result_hash[:action])

      teller_votes_action_type_params_hash = self_generated_action_type_params_per_resident_id[resident_id][:result][ActionResultType::SelfGenerated::ActionTypeParams::KEY_ACTION_TYPES_PARAMS][role_id_string][action_type_id_string]
      if teller_votes_action_type_params_hash[ActionType::TellerVotes::PARAM_LIFETIME_ACTIONS_COUNT]>0
        teller_votes_action_type_params_hash[ActionType::TellerVotes::PARAM_LIFETIME_ACTIONS_COUNT] -= 1
      else
        # counter is already at -1, so this action is infinitely available for this resident
      end
    }

  end

  def modify_action_type_params(action)
    if action.action_type_params.action_type_params_hash[ActionType::TellerVotes::PARAM_LIFETIME_ACTIONS_COUNT] > 0
      action.action_type_params.action_type_params_hash[ActionType::TellerVotes::PARAM_LIFETIME_ACTIONS_COUNT] -= 1
      action.action_type_params.save()
    end
  end

  def set_ordinal
    self.ordinal = 710
  end

end