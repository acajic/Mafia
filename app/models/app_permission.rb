class AppPermission < ActiveRecord::Base

  has_many :app_role_has_app_permissions
  has_many :app_roles, :through => :app_role_has_app_permissions


  PARTICIPATE = 1
  CREATE_GAMES = 2
  ADMIN_READ = 3
  ADMIN_WRITE = 4

end
