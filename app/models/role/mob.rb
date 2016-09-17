class Role::Mob < Role


  def before_creation
    self.affiliation_id = Affiliation::MAFIA
    self.name = 'Mafia'
  end
end