class ActionResolver::ValidVoidVoteMafia < ActionResolver


  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # valid vote mafia vs. void vote mafia

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless valid_results_hash[ActionResultType::VoteMafia].nil?
      valid_results_vote_mafia = valid_results_hash[ActionResultType::VoteMafia]
      void_results_vote_mafia = void_results_hash[ActionResultType::VoteMafia]

      valid_result_vote_mafia = valid_results_vote_mafia[0]
      unless void_results_vote_mafia.nil?
        void_results_vote_mafia.each { |void_result_vote_mafia|

          void_result_vote_mafia[:result][ActionResultType::VoteMafia::KEY_SUCCESS] = valid_result_vote_mafia[:result][ActionResultType::VoteMafia::KEY_SUCCESS]
          if void_result_vote_mafia[:result][ActionResultType::VoteMafia::KEY_SUCCESS]
            void_result_vote_mafia[:result][ActionResultType::VoteMafia::KEY_TARGET_ID] = valid_result_vote_mafia[:result][ActionResultType::VoteMafia::KEY_TARGET_ID]
          end
        }
      end
    end
    # /valid vote mafia vs. void vote mafia
  end

  def set_ordinal
    self.ordinal = 910
  end
end