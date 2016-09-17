class ActionResultType::TellerVotes < ActionResultType

  KEY_SUCCESS = 'success'
  KEY_VOTES_COUNT = 'votes_count'

  def before_creating
    self.name = 'Vote Count'
  end
end