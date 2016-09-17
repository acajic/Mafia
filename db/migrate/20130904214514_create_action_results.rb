class CreateActionResults < ActiveRecord::Migration
  def up
    create_table :action_results do |t|
      t.integer :action_id
      t.integer :action_result_type_id
      t.text :result_json
      t.boolean :is_automatically_generated, :default => false
      t.integer :city_id
      t.integer :day_id
      t.integer :resident_id
      t.integer :role_id
      t.boolean :deleted, :default => false
      t.timestamps
    end

    add_index(:action_results, :action_id)
    add_index(:action_results, :action_result_type_id)
    add_index(:action_results, :city_id)
    add_index(:action_results, :day_id)
    add_index(:action_results, :resident_id)
    add_index(:action_results, :role_id)



  end

  def down
    remove_index(:action_results, :action_id)
    remove_index(:action_results, :action_result_type_id)
    remove_index(:action_results, :city_id)
    remove_index(:action_results, :day_id)
    remove_index(:action_results, :resident_id)
    remove_index(:action_results, :role_id)


    drop_table(:action_results)
  end
end
