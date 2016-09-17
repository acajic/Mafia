class AppRoleHasAppPermission < ActiveRecord::Base
  belongs_to :app_role
  belongs_to :app_permission
end
