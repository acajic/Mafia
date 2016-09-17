class ActionResultType::SelfGenerated < ActionResultType


  def before_creating
    self.name = 'Self Generated Result'
  end

  def self.self_generated_results(city, day, trigger_id)
    # subclass
  end

end