class ActionResolver::VoteTransform < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # valid votes transform KEY_VOTES_COUNT -> KEY_TARGET_ID

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless valid_results_hash[ActionResultType::Vote].nil?
      valid_results_vote = valid_results_hash[ActionResultType::Vote]

      valid_results_vote.each { |valid_result_vote|
        unless valid_result_vote[:result][ActionResultType::Vote::KEY_VOTES_COUNT].nil?
          voted_resident_id = -1
          max_votes = 0
          valid_result_vote[:result][ActionResultType::Vote::KEY_VOTES_COUNT].each_pair { |resident_id, vote_count|
            if vote_count > max_votes
              max_votes = vote_count
              voted_resident_id = resident_id
            elsif vote_count == max_votes && resident_id != voted_resident_id
              voted_resident_id = -1
            end
          }
          valid_result_vote[:result][ActionResultType::Vote::KEY_TARGET_ID] = voted_resident_id
          valid_result_vote[:result].delete(ActionResultType::Vote::KEY_VOTES_COUNT)
        end

      }

      end
    # /valid votes transform KEY_VOTES_COUNT -> KEY_TARGET_ID
  end

  def set_ordinal
    self.ordinal = 900
  end

end