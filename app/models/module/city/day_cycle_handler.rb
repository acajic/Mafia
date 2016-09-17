require_dependency('static/action_result/store_results')
require_dependency('module/action_resolver/resolver')
require_dependency('action.rb')

module Module::City::DayCycleHandler
  include Module::City::Queries
  include Module::City::SelfGenerated
  include Module::City::Starter

  def produce_automatic_actions(trigger_id, day, last_action_type_params_result_per_resident)
    automatic_action_initializers = []
    self.city_has_roles.each { |city_has_role|
      city_has_role.role.action_types.each { |action_type|
        automatic_action_initializers.concat(action_type.generate_automatic_action_hashes(self, day.id, trigger_id, last_action_type_params_result_per_resident))
      }
    }

    Action.create(automatic_action_initializers)
  end

  def action_types_params_result_per_resident(day)
    action_type_params_results = self.action_results.joins('JOIN days ON action_results.day_id = days.id').where(:action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS).where('days.number = ? OR days.number = ?', day.number, day.number-1).order('id DESC')
    action_type_params_result_per_resident = {}
    action_type_params_results.each { |action_types_params_result|
      if action_type_params_result_per_resident[action_types_params_result.resident].nil?
        action_type_params_result_per_resident[action_types_params_result.resident] = action_types_params_result
      end
    }
    action_type_params_result_per_resident
  end

  def handle_day_start
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    current_day = self.current_day(true)

    logger.info('MANUAL LOG - current day: ' + current_day.to_json())
    logger.info('MANUAL LOG - total number of days: ' + self.days.all.count().to_s())

    if current_day.nil?
      logger.error('MANUAL LOG - current day is NIL')
      return
    end

    atp_result_per_resident = self.action_types_params_result_per_resident(current_day)
    self.produce_automatic_actions(Trigger::DAY_START, current_day, atp_result_per_resident)

    ActiveRecord::Base.transaction {
      action_result_initializers = process_actions(current_day, Trigger::DAY_START)
      logger.info('MANUAL LOG - action_result_initializers created: ' + (action_result_initializers ? action_result_initializers.count().to_s() : 'error'))
      ActionResult.create!(action_result_initializers)
      logger.info('MANUAL LOG - Action Results created')
    }

  end



  def handle_night_start
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())


    current_day = self.current_day(true)

    logger.info('MANUAL LOG - current day: ' + current_day.to_json())
    logger.info('MANUAL LOG - total number of days: ' + self.days.all.count().to_s())

    if current_day.nil?
      logger.error('MANUAL LOG - current day is NIL')
      return
    end


    atp_result_per_resident = self.action_types_params_result_per_resident(current_day)
    self.produce_automatic_actions(Trigger::NIGHT_START, current_day, atp_result_per_resident)

    previous_day = current_day

    ActiveRecord::Base.transaction {
      increment_days()
      action_result_initializers = process_actions(previous_day, Trigger::NIGHT_START)
      logger.info('MANUAL LOG - action_result_initializers created: ' + (action_result_initializers ? action_result_initializers.count().to_s() : 'error'))
      ActionResult.create!(action_result_initializers)
      logger.info('MANUAL LOG - Action Results created')
    }

  end

  def process_actions(day, trigger_id)
    all_actions = self.unprocessed_actions(day).to_a()
    valid_actions = self.valid_unprocessed_actions(day).to_a()

    actions_to_process = []
    valid_actions_hash = {}
    void_actions_hash = {}
    valid_actions.each { |action|
      if action.resident_alive == false && action.action_type.require_alive_posting
        next # treat action that resident posted while he was dead as void
      end

      if action.resident.alive == false && action.action_type.require_alive_processing
        next # treat as void the action that resident posted while he was alive, but has died before the action was processed
      end

      all_actions.delete(action)
      if action.action_type.trigger_id != trigger_id && action.action_type.trigger_id != Trigger::BOTH
        next # action is valid but this is not the time to process it
        # e.g. the action is supposed to be processed at DAY_START, but current execution is triggered by NIGHT_START
      end

      actions_to_process << action
      if valid_actions_hash[action.action_type].nil?
        valid_actions_hash[action.action_type] = []
      end
      # all actions are sorted in dictionary where by action types
      valid_actions_hash[action.action_type] << action
    }

    all_actions.each { |action|
      # remaining actions (the ones that weren't classified as 'valid') should be considered 'void'
      if action.action_type.trigger_id != trigger_id && action.action_type.trigger_id != Trigger::BOTH
        next # action is valid but this is not the time to process it
        # e.g. the action is supposed to be processed at DAY_START, but current execution is triggered by NIGHT_START
      end

      actions_to_process << action # void actions are also being processed

      unless (action.role.role_has_action_types.map { |role_has_action_type| role_has_action_type.action_type_id }).include?(action.action_type_id) # check if role conducted an action_type it does not even have at disposal
        next # malformed action
        # e.g. a user posted an Investigate action as Doctor role
        # Malformed actions are just marked as 'processed' because they are placed in 'actions_to_process' array, but they produce no result
      end

      if void_actions_hash[action.action_type].nil?
        void_actions_hash[action.action_type] = []
      end

      void_actions_hash[action.action_type] << action
    }

    valid_results_hash = {}
    all_action_types = ActionType.where(:trigger_id => trigger_id)
    all_action_types.each { |action_type|
      actions_array = valid_actions_hash[action_type]
      valid_results_hash[action_type.action_result_type.class] = action_type.create_valid_action_results(actions_array, self)
    }

    logger.info('MANUAL LOG - Valid actions converted to action results')

    void_results_hash = {}
    all_action_types.each { |action_type|
      actions_array = void_actions_hash[action_type]
      void_results_hash[action_type.action_result_type.class] = action_type.create_void_action_results(actions_array, self)
    }

    logger.info('MANUAL LOG - Void actions converted to action results')

    # create self generated results
    valid_results_hash.merge!(self.self_generated_results(day, trigger_id))

    logger.info('MANUAL LOG - Self generating action results generated')

    ::ActionResolver.resolve_action_results(valid_results_hash, void_results_hash, self, trigger_id) # method declared in Module::ActionResolver::Resolver

    logger.info('MANUAL LOG - Action results resolved')

    Action.where(:id => actions_to_process.map { |action| action.id }).update_all(:is_processed => true)

    result_initializers = []
    result_initializers.concat(self.action_result_initializers_from_hash(valid_results_hash))
    result_initializers.concat(self.action_result_initializers_from_hash(void_results_hash))

    logger.info('MANUAL LOG - Created action results initializers; count: ' + result_initializers.count().to_s())
    result_initializers
  end


  def action_result_initializers_from_hash(results_hash)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())
    logger.info('MANUAL LOG - current day: ' + self.current_day(true).to_json())

    action_result_new_hash_array = []
    results_hash.each_pair { |action_result_type_class, action_result_hash_array|
      if action_result_hash_array.nil?
        next
      end

      action_result_type = action_result_type_class.first()
      action_result_new_hash_array.concat(Static::ActionResult::StoreResults.prepare_for_db(action_result_hash_array, self.current_day(true), action_result_type )) # prepare_for_db declared in Module::ActionResult::StoreResults
    }

    action_result_new_hash_array
  end

end