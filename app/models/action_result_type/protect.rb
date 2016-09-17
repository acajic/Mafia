class ActionResultType::Protect < ActionResultType

  KEY_TARGET_ID = "target_id"
  KEY_SUCCESS = "success"

  def before_creating
    self.name = 'Protection Result'
  end

end