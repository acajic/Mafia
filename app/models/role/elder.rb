class Role::Elder < Role

  def before_creation
    self.affiliation_id = Affiliation::CITIZENS
    self.name = 'Elder'
  end

end