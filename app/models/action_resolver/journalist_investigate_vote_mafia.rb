class ActionResolver::JournalistInvestigateVoteMafia < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # journalist investigate vs mafia vote
    # journalist investigate will receive response that an investigated resident is a mafia member only if both of following criteria are met:
    # 1) resident is a mafia member
    # 2) resident performed "mafia vote" on the night he was investigated by a journalist

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless valid_results_hash[ActionResultType::VoteMafia].nil?
      valid_results_vote_mafia = valid_results_hash[ActionResultType::VoteMafia]
      void_results_vote_mafia = void_results_hash[ActionResultType::VoteMafia]
      if void_results_vote_mafia.nil?
        void_results_vote_mafia = []
      end

      if valid_results_hash[ActionResultType::JournalistInvestigate].nil?
        return
      end

      valid_actions_vote_mafia = []
      valid_results_vote_mafia.each { |valid_result_vote_mafia|
        if valid_result_vote_mafia[:action].nil?
          next
        end
        valid_action_vote_mafia = valid_result_vote_mafia[:action]
        valid_actions_vote_mafia << valid_action_vote_mafia
      }

      action_results_journalist_investigate = valid_results_hash[ActionResultType::JournalistInvestigate]

      action_results_journalist_investigate.each { |action_result_journalist_investigate|
        valid_journalist_investigate_action = action_result_journalist_investigate[:action]
        journalist_investigate_target_id = valid_journalist_investigate_action.input[ActionType::JournalistInvestigate::KEY_TARGET_ID]

        discovered_mafia_members = valid_actions_vote_mafia.select { |action|
          action.resident_id == journalist_investigate_target_id
        }
        if discovered_mafia_members.empty?

        else
          action_result_journalist_investigate[:result][ActionResultType::JournalistInvestigate::KEY_SUCCESS] = true
        end
      }
    end
    # /journalist investigate vs mafia vote
  end

  def set_ordinal
    self.ordinal = 220
  end
end