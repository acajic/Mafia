class Role::Zombie < Role

  def before_creation
    self.affiliation_id = Affiliation::MAFIA
    self.name = 'Zombie'
    self.is_starting_role = false
    true
  end

end