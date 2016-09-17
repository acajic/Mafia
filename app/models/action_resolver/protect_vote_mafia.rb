class ActionResolver::ProtectVoteMafia < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # doctor vs mafiaKill

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless valid_results_hash[ActionResultType::VoteMafia].nil?
      valid_results_vote_mafia = valid_results_hash[ActionResultType::VoteMafia]
      void_results_vote_mafia = void_results_hash[ActionResultType::VoteMafia]
      if void_results_vote_mafia.nil?
        void_results_vote_mafia = []
      end

      valid_result_vote_mafia = valid_results_vote_mafia[0]
      result_hash_vote_mafia = valid_result_vote_mafia[:result]
      vote_mafia_target_id = result_hash_vote_mafia[ActionResultType::VoteMafia::KEY_TARGET_ID]

      if valid_results_hash[ActionResultType::Protect].nil?
        return
      end

      action_results_protect = valid_results_hash[ActionResultType::Protect]

      action_results_protect.each { |action_result_protect|
        result_hash_protect = action_result_protect[:result]


        if result_hash_protect[ActionResultType::Protect::KEY_TARGET_ID] == vote_mafia_target_id
          result_hash_protect[ActionResultType::Protect::KEY_SUCCESS] = true
          if result_hash_vote_mafia[ActionResultType::VoteMafia::KEY_SUCCESS] # enter this block only once, even if two doctors successfully protected the targeted resident
            valid_results_vote_mafia.each { |some_action_result_mafia| # mafia vote failed because doctor protected the target
              some_action_result_mafia[:result][ActionResultType::VoteMafia::KEY_SUCCESS] = false
              # if some_action_result_mafia[:action].nil?
              some_action_result_mafia[:result][ActionResultType::VoteMafia::KEY_TARGET_ID] = -1
                                                                       # end
            }
            void_results_vote_mafia.each { |void_result_vote_mafia|
              void_result_vote_mafia[:result][ActionResultType::VoteMafia::KEY_SUCCESS] = false
              action = void_result_vote_mafia[:action]
              void_result_vote_mafia[:result][ActionResultType::VoteMafia::KEY_TARGET_ID] = action.input[ActionType::VoteMafia::KEY_TARGET_ID] # if doctor saved the target, void action result should not reveal who was the target
            }

            unless void_results_hash[ActionResultType::Protect].nil?
              void_results_hash[ActionResultType::Protect].each { |void_result_hash_protect|
                if void_result_hash_protect[:result][ActionResultType::Protect::KEY_TARGET_ID] == result_hash_vote_mafia[ActionResultType::Protect::KEY_TARGET_ID]
                  void_result_hash_protect[:result][ActionResultType::Protect::KEY_SUCCESS] = true
                end
              }

            end
          end
        end
      }
    end
    # /doctor vs mafiaKill
  end

  def set_ordinal
    self.ordinal = 300
  end
end