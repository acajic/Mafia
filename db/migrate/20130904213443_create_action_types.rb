class CreateActionTypes < ActiveRecord::Migration
  def up
    create_table :action_types do |t|
      t.string :type
      t.string :name
      t.integer :trigger_id
      t.integer :action_result_type_id
      t.text :default_params_json
      t.boolean :require_alive_posting, :default => true
      t.boolean :require_alive_processing, :default => false
      t.boolean :is_single_required, :default => false
      t.boolean :can_submit_manually, :default => true
      t.timestamps
    end

    add_index(:action_types, :action_result_type_id)
    add_index(:action_types, :trigger_id)


  end

  def down
    remove_index(:action_types, :action_result_type_id)
    remove_index(:action_types, :trigger_id)

    drop_table(:action_types)
  end
end
