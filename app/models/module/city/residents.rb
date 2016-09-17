module Module::City::Residents
  def get_resident_by_user_id(user_id)
    self.residents.detect { |resident| resident.user_id == user_id}
  end
end