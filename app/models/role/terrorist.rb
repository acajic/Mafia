class Role::Terrorist < Role

  def before_creation
    self.affiliation_id = Affiliation::MAFIA
    self.name = 'Terrorist'
  end
end