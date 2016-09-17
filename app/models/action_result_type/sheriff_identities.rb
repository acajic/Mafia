class ActionResultType::SheriffIdentities < ActionResultType

  KEY_DEAD_RESIDENTS_ROLES = 'dead_residents_roles'
  KEY_SUCCESS = 'success'

  KEY_RESIDENT_ID = 'resident_id'
  KEY_RESIDENT_ROLE_ID = 'role_id'

  def before_creating
    self.name = 'Revealed Identities'
  end

  def matching(action_result1, action_result2)
    super(action_result1, action_result2) && action_result1.action_id == action_result2.action_id
  end


end