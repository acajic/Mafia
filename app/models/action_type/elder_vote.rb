class ActionType::ElderVote < ActionType

  KEY_TARGET_ID = 'target_id'


  def before_creation
    super
    self.trigger_id = Trigger::NIGHT_START
    self.name = 'Elder Vote'
    self.action_result_type_id = ActionResultType::ELDER_VOTE
  end


  def create_valid_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return
    end

    action_array_per_resident = Action.actions_per_resident(actions)

    action_results = []
    action_array_per_resident.each_pair { |resident, actions|
      vote_counts = {}
      actions.each { |action|

        target_id = action.input[KEY_TARGET_ID]

        unless vote_counts.has_key?(target_id)
          vote_counts[target_id] = 0
        end
        vote_counts[target_id] = 1 # max 1 vote per target resident
      }

      logger.info('MANUAL LOG - valid elder vote actions: ' + vote_counts.to_json())


      action_results << {:action => actions.last,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => city.id,
                         :resident_id => resident.id,
                         :role_id => actions.last.role_id,
                         # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                         :result => {self.action_result_type.class::KEY_VOTES_COUNT => vote_counts},
                         :is_automatically_generated => true}

    }


    action_results
  end

  def create_void_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end


    []
  end

end