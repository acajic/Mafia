class RoleHasDemandedRole < ActiveRecord::Base

  belongs_to :role
  belongs_to :demanded_role, :foreign_key => :demanded_role_id, :class_name => Role.name


  def as_json(options={})
    {
        :id => self.id,
        :demanded_role => self.demanded_role.as_json(Role::JSON_OPTION_SKIP_DEMANDED_ROLES => true, Role::JSON_OPTION_SKIP_IMPLICATED_ROLES => true),
        :quantity_min => self.quantity_min,
        :quantity_max => self.quantity_max,
        :is_demanded_per_resident => self.is_demanded_per_resident
    }
  end

end
