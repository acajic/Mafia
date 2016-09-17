class AppRole < ActiveRecord::Base

  has_many :app_role_has_app_permissions
  has_many :app_permissions, :through => :app_role_has_app_permissions
  has_many :default_users, :class_name => User.name, :inverse_of => :default_app_role
  has_many :granted_app_roles, :dependent => :destroy

  SUPER_ADMIN = 1
  ADMIN = 2
  GAME_CREATOR = 3
  USER = 4

  def as_json(options={})
    app_permissions_hash = {}
    self.app_permissions.each { |app_permission|
      app_permissions_hash[app_permission.id] = app_permission
    }

    {
        id: self.id,
        name: self.name,
        app_permissions: app_permissions_hash
    }
  end

end
