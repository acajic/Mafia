class CreateActions < ActiveRecord::Migration
  def up
    create_table :actions do |t|
      t.integer :resident_id
      t.integer :role_id
      t.integer :action_type_id
      t.integer :day_id
      t.boolean :resident_alive
      t.boolean :is_processed, :default => false
      t.text :input_json
      t.timestamps
    end

    add_index(:actions, :resident_id)
    add_index(:actions, :role_id)
    add_index(:actions, :action_type_id)
    add_index(:actions, :day_id)

  end

  def down
    remove_index(:actions, :resident_id)
    remove_index(:actions, :role_id)
    remove_index(:actions, :action_type_id)
    remove_index(:actions, :day_id)

    drop_table(:actions)

  end
end
