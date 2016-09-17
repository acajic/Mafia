class Role::Forger < Role

  def before_creation
    self.affiliation_id = Affiliation::MAFIA
    self.name = 'Forger'
  end

end