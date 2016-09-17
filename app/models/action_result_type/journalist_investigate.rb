class ActionResultType::JournalistInvestigate < ActionResultType

  KEY_TARGET_ID = "target_id"
  KEY_SUCCESS = "success"

  def before_creating
    self.name = 'Journalist Investigation Result'
  end
end