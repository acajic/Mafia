class ActionResolver::VoteForgerVote < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # vote results + forger vote results

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless valid_results_hash[ActionResultType::Vote].nil? || valid_results_hash[ActionResultType::ForgerVote].nil?

      valid_results_vote = valid_results_hash[ActionResultType::Vote]


      valid_results_forger_vote = valid_results_hash[ActionResultType::ForgerVote]

      sum_votes_count = {}
      valid_results_forger_vote.each { |valid_result_forger_vote|
        votes_count = valid_result_forger_vote[:result][ActionResultType::ForgerVote::KEY_VOTES_COUNT]

        logger.info('MANUAL LOG - valid ForgerVote result for resident ' + valid_result_forger_vote[:resident_id].to_s())
        logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s() + ': forger vote result votes_count: ' + votes_count.to_json())

        votes_count.each_pair { |resident_id, vote_count|
          if sum_votes_count[resident_id].nil?
            sum_votes_count[resident_id] = 0
          end
          sum_votes_count[resident_id] += vote_count
        }
      }



      valid_results_vote.each { |valid_result_vote|
        if valid_result_vote[:result][ActionResultType::Vote::KEY_VOTES_COUNT].nil?
          if sum_votes_count.count > 0
            valid_result_vote[:result][ActionResultType::Vote::KEY_VOTES_COUNT] = {}
            valid_result_vote[:result].delete(ActionResultType::Vote::KEY_TARGET_ID)
          else
            return
          end
        end

        if valid_result_vote[:resident_id].nil?
          logger.info('MANUAL LOG - valid votes before merging with forger votes: ' + valid_result_vote[:result][ActionResultType::Vote::KEY_VOTES_COUNT].to_json())
        end

        valid_result_vote[:result][ActionResultType::Vote::KEY_VOTES_COUNT].update(sum_votes_count) { |resident_id, old_vote_count, additional_vote_count|
          old_vote_count + additional_vote_count
        }

        if valid_result_vote[:resident_id].nil?
          logger.info('MANUAL LOG - valid votes after merging with forger votes: ' + valid_result_vote[:result][ActionResultType::Vote::KEY_VOTES_COUNT].to_json())
        end
      }

    end
    # /vote results + forger vote results
  end

  def set_ordinal
    self.ordinal = 551
  end

end