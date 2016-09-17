class ActionResultType::RevivalOccurred < ActionResultType

  KEY_DAYS_UNTIL_REVEAL = 'days_until_reveal'

  def before_creating
    self.name = 'Revival Occurred'
  end

  def matching(action_result1, action_result2)
    super(action_result1, action_result2) && action_result1.action_id == action_result2.action_id
  end


end