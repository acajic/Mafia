class ActionResultType::ForgerVote < ActionResultType


  KEY_VOTES_COUNT = 'votes_count'

  def before_creating
    self.name = 'Forger Vote'
  end


end