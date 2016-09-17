class Role::Citizen < Role

  def before_creation
    self.affiliation_id = Affiliation::CITIZENS
    self.name = 'Citizen'
  end

end