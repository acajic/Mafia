class Role::Doctor < Role

  def before_creation
    self.affiliation_id = Affiliation::CITIZENS
    self.name = 'Doctor'
  end

end