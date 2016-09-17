class ActionResolver::VoteTellerVotesSGResidents < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # vote vs. teller votes

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    total_vote_count = 0
    voted_resident_id = -1
    generic_vote_result = nil

    if valid_results_hash[ActionResultType::TellerVotes] && valid_results_hash[ActionResultType::Vote]

      valid_result_votes = valid_results_hash[ActionResultType::Vote]


      valid_vote_results_per_resident_id = {}


      generic_vote_result = nil
      valid_result_votes.each { |valid_result_vote|
        if valid_result_vote[:action].nil?
          generic_vote_result = valid_result_vote
          total_vote_count = 0

          voted_resident_id = -1
          max_votes = 0
          unless generic_vote_result[:result][ActionResultType::Vote::KEY_VOTES_COUNT].nil?
            generic_vote_result[:result][ActionResultType::Vote::KEY_VOTES_COUNT].each_pair { |resident_id, vote_count|
              total_vote_count += vote_count

              if vote_count > max_votes
                max_votes = vote_count
                voted_resident_id = resident_id
              elsif vote_count == max_votes && resident_id != voted_resident_id
                voted_resident_id = -1
              end
            }
          end

          # this may be generic ActionResult::Vote, intended for resident that did not participate in public voting
          # this result doesn't count as a vote
          next
        end

        unless valid_result_vote[:resident_id].nil?
          valid_vote_results_per_resident_id[valid_result_vote[:resident_id]] = valid_result_vote
        end
      }


      valid_results_teller_votes = valid_results_hash[ActionResultType::TellerVotes]

      valid_results_teller_votes.each { |valid_result_teller_votes|
        if valid_result_teller_votes[:result][ActionResultType::TellerVotes::KEY_SUCCESS]
          votes_count = nil
          if valid_vote_results_per_resident_id[valid_result_teller_votes[:resident_id]].nil?
            votes_count = generic_vote_result[:result][ActionResultType::Vote::KEY_VOTES_COUNT]
          else
            votes_count = valid_vote_results_per_resident_id[valid_result_teller_votes[:resident_id]][:result][ActionResultType::Vote::KEY_VOTES_COUNT]
          end

          logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s() + ': votes_count being passed to teller_votes action result: ' + votes_count.to_json())

          valid_result_teller_votes[:result][ActionResultType::TellerVotes::KEY_VOTES_COUNT] = votes_count
        end
      }

    end

    # for void TellerVotes action, generate random distribution of votes but in order to satisfy actual result of voting
    unless void_results_hash[ActionResultType::TellerVotes].nil? || valid_results_hash[ActionResultType::Vote].nil?

      unless voted_resident_id != -1 || valid_results_hash[ActionResultType::Vote].nil?
        valid_result_votes = valid_results_hash[ActionResultType::Vote]

        valid_vote_results_per_resident_id = {}

        generic_vote_result = valid_result_votes.select { |valid_vote_result| valid_vote_result[:action].nil? }.first

        total_vote_count = 0

        voted_resident_id = -1
        max_votes = 0
        unless generic_vote_result[:result][ActionResultType::Vote::KEY_VOTES_COUNT].nil?
          generic_vote_result[:result][ActionResultType::Vote::KEY_VOTES_COUNT].each_pair { |resident_id, vote_count|
            total_vote_count += vote_count

            if vote_count > max_votes
              max_votes = vote_count
              voted_resident_id = resident_id
            elsif vote_count == max_votes && resident_id != voted_resident_id
              voted_resident_id = -1
            end
          }
        end
      end


      valid_result_vote = generic_vote_result

      alive_residents_generic = nil
      alive_residents_per_resident_id = {}
      # go through self_generated_residents results for each resident, fetch number of alive residents and generate random distributions based on these counts
      if valid_results_hash[ActionResultType::SelfGenerated::Residents].nil?

      else
        valid_results_hash[ActionResultType::SelfGenerated::Residents].each { |self_generated_result_residents|
          residents_array = self_generated_result_residents[:result][ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS].dup()
          residents_array.keep_if { |resident_hash| resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE]}

          if self_generated_result_residents[:resident_id].nil?
            alive_residents_generic = residents_array
          else
            alive_residents_per_resident_id[self_generated_result_residents[:resident_id]] = residents_array
          end

        }
      end

      void_results_teller_votes = void_results_hash[ActionResultType::TellerVotes]

      void_results_teller_votes.each { |void_result_teller_votes|
        action = void_result_teller_votes[:action]
        resident_id = void_result_teller_votes[:resident_id]
        alive_residents_for_current_user = alive_residents_per_resident_id[resident_id]
        if alive_residents_for_current_user.nil?
          alive_residents_for_current_user = alive_residents_generic
        end
        alive_residents_count = alive_residents_for_current_user.length

        number_of_votes = alive_residents_count
        if alive_residents_count > 5
          number_of_votes -= 1 # -1 in order to not to seem that all residents voted, so it is harder to catch void action in a lie
        end


        min_votes_for_conviction = (number_of_votes/2.0).ceil
        votes_for_convicted = min_votes_for_conviction + rand(number_of_votes-min_votes_for_conviction)

        if voted_resident_id>0
          remaining_alive_residents = alive_residents_for_current_user.dup()

          vote_counter = {voted_resident_id => votes_for_convicted}

          number_of_votes -= votes_for_convicted
          selected_resident_id = voted_resident_id
          while number_of_votes>0
            remaining_alive_residents.delete_if { |resident_hash| resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == selected_resident_id}
            sample_resident_hash = remaining_alive_residents.sample(1).first()
            selected_resident_id = sample_resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID]
            secondary_votes = 1 + rand(number_of_votes)
            if secondary_votes == votes_for_convicted
              secondary_votes -= 1
            end
            number_of_votes -= secondary_votes
            vote_counter[selected_resident_id] = secondary_votes
          end


        else

          selected_resident_id = alive_residents_for_current_user.sample()[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID]
          remaining_alive_residents = alive_residents_for_current_user.dup().delete_if { |resident_hash| resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == selected_resident_id}
          votes_for_convicted = rand(2..min_votes_for_conviction)
          number_of_votes -= votes_for_convicted
          vote_counter = {selected_resident_id => votes_for_convicted}


          selected_resident_id = remaining_alive_residents.sample()[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID]
          remaining_alive_residents.delete_if { |resident_hash| resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == selected_resident_id}
          number_of_votes -= votes_for_convicted
          vote_counter[selected_resident_id] = votes_for_convicted

          while number_of_votes>0
            sample_resident_hash = remaining_alive_residents.sample()
            selected_resident_id = sample_resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID]
            secondary_votes = 1 + rand([number_of_votes, votes_for_convicted].min)
            number_of_votes -= secondary_votes
            vote_counter[selected_resident_id] = secondary_votes
            remaining_alive_residents.delete_if { |resident_hash| resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == selected_resident_id}
          end

        end

        if void_result_teller_votes[:result][ActionResultType::TellerVotes::KEY_SUCCESS]
          void_result_teller_votes[:result][ActionResultType::TellerVotes::KEY_VOTES_COUNT] = vote_counter
        end


      }

    end
    # /vote vs. teller votes
  end

  def set_ordinal
    self.ordinal = 700
  end
end