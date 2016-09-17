class Role::Teller < Role


  def before_creation
    self.affiliation_id = Affiliation::CITIZENS
    self.name = 'Teller'
  end

end