class ActionResultType::ResidentBecameSheriff < ActionResultType

  def before_creating
    self.name = 'Resident Became Sheriff'
  end

end