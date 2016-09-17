class CreateInitialAppRoles < ActiveRecord::Migration
  def up
    create_table :initial_app_roles do |t|
      t.string :description
      t.string :email
      t.string :email_pattern
      t.integer :app_role_id, :default => AppRole::USER
      t.integer :priority, :default => 100
      t.boolean :enabled, :default => true
      t.timestamps
    end
    add_index(:initial_app_roles, :app_role_id)
  end

  def down
    remove_index(:initial_app_roles, :app_role_id)

    drop_table(:initial_app_roles)
  end
end
