class CreateRoleHasDemandedRoles < ActiveRecord::Migration
  def up
    create_table :role_has_demanded_roles do |t|
      t.integer :role_id
      t.integer :demanded_role_id
      t.integer :quantity_min, :default => 0
      t.integer :quantity_max
      t.boolean :is_demanded_per_resident, :default => false
      t.timestamps
    end
    add_index :role_has_demanded_roles, :role_id
    add_index :role_has_demanded_roles, :demanded_role_id
  end


  def down
    remove_index :role_has_demanded_roles, :role_id
    remove_index :role_has_demanded_roles, :demanded_role_id
    drop_table :role_has_demanded_roles
  end
end
