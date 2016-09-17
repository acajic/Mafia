class CreateCityHasRoles < ActiveRecord::Migration


  def up
    create_table :city_has_roles do |t|
      t.integer :city_id
      t.integer :role_id
      t.text :action_types_params_json, :default => nil
      t.timestamps
    end

    add_index(:city_has_roles, :city_id)
    add_index(:city_has_roles, :role_id)

  end


  def down
    remove_index(:city_has_roles, :city_id)
    remove_index(:city_has_roles, :role_id)

    drop_table(:city_has_roles)
  end
end
