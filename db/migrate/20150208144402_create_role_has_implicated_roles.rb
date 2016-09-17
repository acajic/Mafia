class CreateRoleHasImplicatedRoles < ActiveRecord::Migration
  def up
    create_table :role_has_implicated_roles do |t|
      t.integer :role_id
      t.integer :implicated_role_id
      t.timestamps
    end
    add_index :role_has_implicated_roles, :role_id
    add_index :role_has_implicated_roles, :implicated_role_id
  end

  def down
    remove_index :role_has_implicated_roles, :role_id
    remove_index :role_has_implicated_roles, :implicated_role_id
    drop_table :role_has_implicated_roles
  end
end
