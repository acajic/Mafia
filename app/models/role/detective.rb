class Role::Detective < Role

  def before_creation
    self.affiliation_id = Affiliation::CITIZENS
    self.name = 'Detective'
  end
end