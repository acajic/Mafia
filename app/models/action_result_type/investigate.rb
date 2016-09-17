class ActionResultType::Investigate < ActionResultType

  KEY_TARGET_ID = 'target_id'
  KEY_SUCCESS = 'success'

  def before_creating
    self.name = 'Investigation Result'
  end
end