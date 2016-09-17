class Role::Fugitive < Role


  def before_creation
    self.affiliation_id = Affiliation::MAFIA
    self.name = 'Fugitive'
  end
end