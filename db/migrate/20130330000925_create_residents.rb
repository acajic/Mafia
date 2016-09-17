class CreateResidents < ActiveRecord::Migration

  def up
    create_table :residents do |t|
      t.integer :user_id
      t.string :name
      t.integer :city_id
      t.integer :role_id, :default => nil
      t.integer :saved_role_id, :default => nil
      t.boolean :role_seen, :default => false
      t.boolean :alive, :default => true
      t.timestamp :died_at, :default => nil
      t.timestamps
    end

    add_index(:residents, :user_id)
    add_index(:residents, :city_id)
    add_index(:residents, :role_id)
    add_index(:residents, :saved_role_id)

  end

  def down
    remove_index(:residents, :user_id)
    remove_index(:residents, :city_id)
    remove_index(:residents, :role_id)
    remove_index(:residents, :saved_role_id)

    drop_table(:residents)
  end
end
