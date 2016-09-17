class CreateRoleHasActionTypes < ActiveRecord::Migration

  def up
    create_table :role_has_action_types do |t|
      t.integer :role_id
      t.integer :action_type_id
      t.text :action_type_params_json
      t.timestamps
    end

    add_index(:role_has_action_types, :role_id)
    add_index(:role_has_action_types, :action_type_id)

  end

  def down
    remove_index(:role_has_action_types, :role_id)
    remove_index(:role_has_action_types, :action_type_id)

    drop_table(:role_has_action_types)
  end
end
