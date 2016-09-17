class ActionType::VoteMafia < ActionType

  KEY_TARGET_ID = "target_id"

  def before_creation
    super
    self.trigger_id = Trigger::DAY_START
    self.name = 'Mafia Kill'
    self.action_result_type_id = ActionResultType::VOTE_MAFIA
  end




  def create_valid_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    vote_counts = {}
    max_votes = 0
    voted_resident_id = -1

    city_id = city.id
    action_results = []
    alive_mafia_residents_count = city.residents.select { |resident| resident.role.affiliation_id == Affiliation::MAFIA && resident.alive }.count

    if actions.nil? || actions.empty?
      logger.info('ZERO valid VoteMafia actions')
      # do nothing
    else
      logger.info("Valid VoteMafia actions #{ actions.to_json() }")

      actions_per_resident = Action.latest_action_per_resident(actions)

      actions_per_resident.each_pair { |resident, action|

        target_id = action.input[KEY_TARGET_ID]

        unless vote_counts.has_key?(target_id)
          vote_counts[target_id] = 0
        end
        vote_counts[target_id] += 1

        if vote_counts[target_id] == max_votes
          voted_resident_id = -1
          next
        end

        if vote_counts[target_id] > max_votes
          max_votes = vote_counts[target_id]
          voted_resident_id = target_id
        end
      }

      if voted_resident_id != -1 && vote_counts[voted_resident_id] < (alive_mafia_residents_count / 2).floor + 1
        voted_resident_id = -1
      end
    end



    success = voted_resident_id != -1

    unless actions_per_resident.nil?
      actions_per_resident.each_pair { |resident, action| # add one result per each mafia member, this is for Resolvers
        action_results << {:action => action,
                           :action_result_type_id => self.action_result_type_id,
                           :city_id => resident.city_id,
                           :resident_id => resident.id,
                           :role_id => action.role_id,
                           # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                           :result => {self.action_result_type.class::KEY_TARGET_ID => voted_resident_id, self.action_result_type.class::KEY_SUCCESS => success},
                           :is_automatically_generated => true}
      }
    end

    action_results << {:action => nil, # this action result will actually be returned from the server when GETing action results
                       :action_result_type_id => self.action_result_type_id,
                       :city_id => city_id,
                       :resident_id => nil, #resident.id,
                       :role_id => nil, #action.role_id,
                       # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                       :result => {self.action_result_type.class::KEY_TARGET_ID => voted_resident_id, self.action_result_type.class::KEY_SUCCESS => success},
                       :is_automatically_generated => true}


    action_results #return array of ActionResult init hashes

  end

  def create_void_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      logger.info('ZERO void VoteMafia actions')
      return nil
    end

    logger.info("Void VoteMafia actions #{ actions.to_json() }")

    actions_per_resident = Action.latest_action_per_resident(actions)

    action_results = []
    #no need to create void action result when a general mafia_vote result is being created for every resident
=begin
    actions_per_resident.each_pair { |resident, action|

      action_results << {:action => action,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => resident.city_id,
                         :resident_id => resident.id,
                         :role_id => action.role_id,
                         # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                         :result => {self.action_result_type.class::KEY_TARGET_ID => action.input[KEY_TARGET_ID], self.action_result_type.class::KEY_SUCCESS => false},
                         :is_automatically_generated => true}
    }
=end

    #    ActionResult.create(action_results)
    action_results #return array of ActionResult init hashes
  end

end