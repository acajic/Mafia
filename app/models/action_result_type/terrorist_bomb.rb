class ActionResultType::TerroristBomb < ActionResultType

  KEY_TARGET_IDS = "target_ids"
  KEY_SUCCESS = "success"

  def before_creating
    self.name = 'Terrorist Bombing'
  end

  def matching(action_result1, action_result2)
    return action_result1.action_id == action_result2.action_id
  end


end