class CreateResidentRoleActionTypeParamsModels < ActiveRecord::Migration


  def up
    create_table :resident_role_action_type_params_models do |t|
      t.integer :resident_id
      t.integer :role_id
      t.integer :action_type_id
      t.text :action_type_params_json
      t.text :original_action_type_params_json
      t.timestamps
    end

    add_index(:resident_role_action_type_params_models, :resident_id)
    add_index(:resident_role_action_type_params_models, :role_id)
    add_index(:resident_role_action_type_params_models, :action_type_id)


  end

  def down
    remove_index(:resident_role_action_type_params_models, :resident_id)
    remove_index(:resident_role_action_type_params_models, :role_id)
    remove_index(:resident_role_action_type_params_models, :action_type_id)

    drop_table(:resident_role_action_type_params_models)

  end
end
