class ActionType::Vote < ActionType

  KEY_TARGET_ID = 'target_id'


  def before_creation
    super
    self.trigger_id = Trigger::NIGHT_START
    self.name = 'Vote'
    self.action_result_type_id = ActionResultType::VOTE
  end


  def create_valid_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      action_results = []

      # serve one ActionResult::Vote for all residents
      action_results << {:action => nil,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => city.id,
                         :resident_id => nil,
                         :role_id => nil, # it will be visible for resident, whatever role he assumes
                         # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                         :result => {self.action_result_type.class::KEY_TARGET_ID => -1},
                         :is_automatically_generated => true}
      return action_results
    else
      city_id = nil
      actions_per_resident = Action.latest_action_per_resident(actions)

      vote_counts = {}
      # max_votes = 0
      # voted_resident_id = -1

      actions_per_resident.each_pair { |resident, action|
        if city_id.nil?
          city_id = resident.city_id
        end

        target_id = action.input[KEY_TARGET_ID]

        unless vote_counts.has_key?(target_id)
          vote_counts[target_id] = 0
        end
        vote_counts[target_id] += 1

=begin
        if vote_counts[target_id] == max_votes
          voted_resident_id = -1
          next
        end
=end

=begin
        if vote_counts[target_id] > max_votes
          max_votes = vote_counts[target_id]
          voted_resident_id = target_id
        end
=end
      }

      action_results = []

      # serve one ActionResult::Vote for all residents
      action_results << {:action => nil,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => city_id,
                         :resident_id => nil,
                         :role_id => nil, # it will be visible for resident, whatever role he assumes
                         # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                         :result => {self.action_result_type.class::KEY_VOTES_COUNT => vote_counts.dup()},
                         :is_automatically_generated => true}

      logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s() + ': vote counts: ' + vote_counts.to_json())

      # serve one ActionResult::Vote per Action::Vote, so that these results can be used for counting votes while resolving with ActionResult::TellerVotes
      actions_per_resident.each_pair { |resident, action|
        unless resident.alive
          next
        end

        action_results << {:action => action,
                           :action_result_type_id => self.action_result_type_id,
                           :city_id => resident.city_id,
                           :resident_id => resident.id,
                           :role_id => nil, # it will be visible for resident, whatever role he assumes
                           # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                           :result => {self.action_result_type.class::KEY_VOTES_COUNT => vote_counts.dup()},
                           :is_automatically_generated => true}
      }

      return action_results #return array of ActionResult init hashes
    end


  end

  def create_void_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end

    action_results = []


    #no need to create void result for Vote because a single general Vote result gets created for all residents
=begin
    actions_per_resident = Action.latest_action_per_resident(actions)



    actions_per_resident.each_pair { |resident, action|
      unless resident.alive
        next
      end

      action_results << {:action => action,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => resident.city_id,
                         :resident_id => resident.id,
                         :role_id => nil, # it will be visible for resident, whatever role he assumes
                         # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                         :result => {self.action_result_type.class::KEY_TARGET_ID => -1},
                         :is_automatically_generated => true}
    }
=end

    action_results #return array of ActionResult init hashes
  end

end