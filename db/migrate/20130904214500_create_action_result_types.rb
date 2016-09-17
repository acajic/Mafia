class CreateActionResultTypes < ActiveRecord::Migration

  def up
    create_table :action_result_types do |t|
      t.string :type
      t.string :name
      t.string :description # only used for action result types that are self generated, so that game creator knows which of the self-generating action result types he will enable
      t.boolean :is_self_generated, :default => false
      t.integer :trigger_id
      t.timestamps
    end

    add_index(:action_result_types, :trigger_id)

  end

  def down
    remove_index(:action_result_types, :trigger_id)

    drop_table(:action_result_types)
  end
end
