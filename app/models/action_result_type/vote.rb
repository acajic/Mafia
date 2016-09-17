class ActionResultType::Vote < ActionResultType

  KEY_TARGET_ID = 'target_id'
  KEY_VOTES_COUNT = 'votes_count'

  def before_creating
    self.name = 'Public Vote'
  end


end