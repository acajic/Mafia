class CreateRoles < ActiveRecord::Migration
  def up
    create_table :roles do |t|
      t.integer :affiliation_id
      t.string :type
      t.string :name
      t.boolean :is_starting_role, :default => true
      t.timestamps
    end

    add_index(:roles, :affiliation_id)
  end

  def down
    remove_index(:roles, :affiliation_id)
    drop_table(:roles)
  end
end
