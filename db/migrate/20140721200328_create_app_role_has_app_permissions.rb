class CreateAppRoleHasAppPermissions < ActiveRecord::Migration


  def up
    create_table :app_role_has_app_permissions do |t|
      t.integer :app_role_id
      t.integer :app_permission_id
      t.timestamps
    end

    add_index(:app_role_has_app_permissions, :app_role_id)
    add_index(:app_role_has_app_permissions, :app_permission_id)

  end


  def down
    remove_index(:app_role_has_app_permissions, :app_role_id)
    remove_index(:app_role_has_app_permissions, :app_permission_id)

    drop_table(:app_role_has_app_permissions)
  end
end
