class RoleHasImplicatedRole < ActiveRecord::Base
  belongs_to :role
  belongs_to :implicated_role, :foreign_key => :implicated_role_id, :class_name => Role.name

  def as_json(options={})
    {
        :id => self.id,
        :implicated_role => self.implicated_role.as_json(Role::JSON_OPTION_SKIP_DEMANDED_ROLES => true, Role::JSON_OPTION_SKIP_IMPLICATED_ROLES => true)
    }
  end

end
