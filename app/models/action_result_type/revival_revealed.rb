class ActionResultType::RevivalRevealed < ActionResultType

  KEY_TARGET_ID = 'target_id'

  def before_creating
    self.name = 'Revival Revealed'
  end

  def matching(action_result1, action_result2)
    super(action_result1, action_result2) && action_result1.action_id == action_result2.action_id
  end


end