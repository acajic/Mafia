class Role::Journalist < Role

  def before_creation
    self.affiliation_id = Affiliation::CITIZENS
    self.name = 'Journalist'
  end
end