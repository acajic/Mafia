class ActionType::InitiateRevival < ActionType

  KEY_TARGET_ID = :target_id

  PARAM_REVIVAL_DELAY = 'revival_delay'

  def before_creation
    super
    self.trigger_id = Trigger::ASYNC
    @default_params = action_type_params()
    self.default_params_json = self.default_params.to_json()

    self.name = 'Initiate Revival'
    self.action_result_type_id = nil
  end

  def action_type_params
    {
        PARAM_REVIVAL_DELAY => '5m'
    }
  end

  def params_valid(action_type_params)
    if action_type_params.nil?
      return true
    end

    revival_delay_correct_format = /^[1-9]\d*[smh]$/.match(action_type_params[PARAM_REVIVAL_DELAY])
    revival_delay_correct_format
  end

  def action_valid?(action, action_type_params_per_resident_role_action_type)
    unless super
      return false
    end

    mafia_residents = action.city.residents.joins('LEFT JOIN roles ON residents.role_id = roles.id').where('roles.affiliation_id = ?', Affiliation::MAFIA)

    mafia_members_result = action.resident.action_results.where(:action_result_type_id => ActionResultType::MAFIA_MEMBERS).order('action_results.id DESC').first()
    if mafia_members_result.nil?
      return false
    end

    mafia_resident_ids_from_result = mafia_members_result.result[ActionResultType::SingleRequired::MafiaMembers::KEY_MAFIA_MEMBERS]
    mafia_resident_ids = mafia_residents.map do |r|
      r.id
    end

    is_result_correct = mafia_resident_ids_from_result.sort == mafia_resident_ids.sort
    is_result_correct
  end


  def create_valid_action_results(actions, city)
    # actions are async
  end

  def create_void_action_results(actions, city)
    # actions are async
  end

  def start_valid_async_execution(action)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    previous_actions = Action.includes(:resident).where(:action_type_id => action.action_type_id).where('actions.resident_id' => action.resident_id).where('actions.is_processed' => false).where('actions.id != ?', action.id)
    previous_actions.each { |previous_action|
      previous_action.stop_async_action()
    }
    previous_actions.update_all(:is_processed => true)

    if action.input[KEY_TARGET_ID] != -1
      schedule_revival(action)
    end
  end

  def start_void_async_execution(action)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    action.update(:is_processed => true)
    # do nothing
    # do not schedule revival because action is void
  end

  # @param [Action] action
  def schedule_revival(action)
    scheduler = AppConfig.instance.scheduler
    params = action.action_type_params(false).action_type_params_hash
    job = scheduler.schedule_in(params[PARAM_REVIVAL_DELAY], :tag => action.scheduler_tag) {

      self.perform_revival_action(action)
    }

  end


  def perform_revival_action(action)
    if action.action_type_id != ActionType::INITIATE_REVIVAL
      return
    end

    target_id = action.input[KEY_TARGET_ID]

    target_resident = Resident.find(target_id)

    if target_resident.city_id != action.city.id
      # resident not in appropriate city
      return
    end

    Action.create(:resident_id => action.resident.id, :role_id => action.role.id, :action_type_id => ActionType::REVIVE, :day_id => action.day.id, :input => { ActionType::Revive::KEY_TARGET_ID => target_id })

    action.is_processed = true
    action.save()
  end



  def stop_valid_async_execution(action)
    self.unschedule_revival(action)
  end

  def stop_void_async_execution(action)
    # nothing to do here, detonation was not even scheduled
  end

  # @param [Action] action
  def unschedule_revival(action)
    scheduler = AppConfig.instance.scheduler
    jobs = scheduler.jobs(:tag => action.scheduler_tag)
    jobs.each { |job|
      job.unschedule()
    }
  end

end