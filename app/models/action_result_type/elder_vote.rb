class ActionResultType::ElderVote < ActionResultType


  KEY_VOTES_COUNT = 'votes_count'

  def before_creating
    self.name = 'Elder Vote'
  end


end