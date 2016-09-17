class Role::Sheriff < Role


  def before_creation
    self.affiliation_id = Affiliation::CITIZENS
    self.name = 'Sheriff'
  end
end