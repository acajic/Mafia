class CreateResidentPreviousRoles < ActiveRecord::Migration

  def up
    create_table :resident_previous_roles do |t|
      t.integer :resident_id
      t.integer :previous_role_id
      t.integer :day_id
      t.timestamps
    end

    add_index(:resident_previous_roles, :resident_id)
    add_index(:resident_previous_roles, :previous_role_id)
    add_index(:resident_previous_roles, :day_id)

  end

  def down
    remove_index(:resident_previous_roles, :resident_id)
    remove_index(:resident_previous_roles, :previous_role_id)
    remove_index(:resident_previous_roles, :day_id)
    drop_table(:resident_previous_roles)
  end
end
