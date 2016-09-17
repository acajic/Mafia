class CreateGrantedAppRoles < ActiveRecord::Migration
  def up
    create_table :granted_app_roles do |t|
      t.integer :user_id
      t.integer :subscription_purchase_id
      t.integer :app_role_id
      t.text :description
      t.datetime :expiration_date
      t.timestamps
    end
    add_index :granted_app_roles, :user_id
    add_index :granted_app_roles, :subscription_purchase_id
    add_index :granted_app_roles, :app_role_id
  end

  def down
    remove_index :granted_app_roles, :user_id
    remove_index :granted_app_roles, :subscription_purchase_id
    remove_index :granted_app_roles, :app_role_id
    drop_table :granted_app_roles
  end
end
