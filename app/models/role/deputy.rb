class Role::Deputy < Role
  # formerly SilentSheriff

  def before_creation
    self.affiliation_id = Affiliation::CITIZENS
    self.name = 'Deputy'
  end
end