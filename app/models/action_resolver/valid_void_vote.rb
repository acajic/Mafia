class ActionResolver::ValidVoidVote < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # valid vote vs. void vote

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless valid_results_hash[ActionResultType::Vote].nil?
      valid_results_vote = valid_results_hash[ActionResultType::Vote]
      void_results_vote = void_results_hash[ActionResultType::Vote]

      valid_result_vote = valid_results_vote[0]
      if void_results_vote.nil?
        return
      else
        void_results_vote.each { |void_result_vote|
          void_result_vote[:result][ActionResultType::Vote::KEY_TARGET_ID] = valid_result_vote[:result][ActionResultType::Vote::KEY_TARGET_ID]
        }
      end

    end
    # /valid vote vs. void vote
  end

  def set_ordinal
    self.ordinal = 920
  end

end