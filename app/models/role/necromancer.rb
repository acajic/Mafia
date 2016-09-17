class Role::Necromancer < Role

  def before_creation
    self.affiliation_id = Affiliation::MAFIA
    self.name = 'Necromancer'
  end

end