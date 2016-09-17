class ActionType::SingleRequired::MafiaMembers < ActionType

  def before_creation
    super
    self.trigger_id = Trigger::NO_TRIGGER
    self.is_single_required = true
    self.action_result_type_id = ActionResultType::MAFIA_MEMBERS
    self.name = 'Mafia Members'
  end

  def single_required_action_initializer(resident, role_id, action_results)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    should_create_action_result = false


    if action_results.nil? || action_results.empty?
      should_create_action_result = true
    end


    if should_create_action_result
      return {:resident_id => resident ? resident.id : nil, :role_id => role_id, :action_type_id => self.id, :day => nil, :input_json => nil, :is_processed => true}
    else
      return nil
    end


  end

  def create_valid_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end

    actions_per_resident = Action.latest_action_per_resident(actions)
    action_results = []
    actions_per_resident.each_pair { |resident, action|
      mafia_members = city.residents.select { |resident_inner| resident_inner.role.affiliation_id == Affiliation::MAFIA }
      mafia_member_ids = mafia_members.map { |resident_inner| resident_inner.id }

      action_results << {:action => action,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => resident.city_id,
                         :resident_id => resident.id,
                         :role_id => nil, # action.role_id,
                         # no need to set :day property, it should be nil for this ActionResult
                         :result => {self.action_result_type.class::KEY_MAFIA_MEMBERS => mafia_member_ids},
                         :is_automatically_generated => true}
    }

    action_results #return array of ActionResult init hashes
  end

  def create_void_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if actions.nil? || actions.empty?
      return nil
    end

    actions_per_resident = Action.latest_action_per_resident(actions)

    action_results = []
    actions_per_resident.each_pair { |resident, action|
      mafia_members = city.residents.select { |resident_inner|
        resident_inner.role.affiliation_id == Affiliation::MAFIA
      }

      mafia_member_ids = [resident.id]

      mafia_members = city.residents.where('id != ?', resident.id).sample(mafia_members.length-1)
      mafia_member_ids.concat(mafia_members.map { |resident_inner| resident_inner.id })


      action_results << {:action => action,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => resident.city_id,
                         :resident_id => resident.id,
                         :role_id => nil, #action.role_id,
                         # no need to set :day property, it should be nil for this ActionResult
                         :result => {self.action_result_type.class::KEY_MAFIA_MEMBERS => mafia_member_ids},
                         :is_automatically_generated => true}
    }

    action_results #return array of ActionResult init hashes
  end

end