class ActionResultType::SingleRequired::MafiaMembers < ActionResultType

  KEY_MAFIA_MEMBERS = 'mafia_members'

  def before_creating
    self.name = 'Mafia Members'
  end

  def matching(action_result1, action_result2)
    true
  end

  def action_result_will_be_created_based_on_hash(action_result_hash)
    Rails.logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())
    action_result_hash[:day_id] = nil
  end

end