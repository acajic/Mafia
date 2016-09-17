module Module::Action::Queries

=begin
  def is_valid
    self.role.action_types.include?(self.action_type) && self.resident.role_id == self.role_id && self.resident.alive
  end
=end

end