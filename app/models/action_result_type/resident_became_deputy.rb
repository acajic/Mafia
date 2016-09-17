class ActionResultType::ResidentBecameDeputy < ActionResultType

  def before_creating
    self.name = 'Resident Became Deputy'
  end

end