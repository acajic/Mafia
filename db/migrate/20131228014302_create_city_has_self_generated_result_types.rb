class CreateCityHasSelfGeneratedResultTypes < ActiveRecord::Migration


  def up
    create_table :city_has_self_generated_result_types do |t|
      t.integer :city_id
      t.integer :action_result_type_id
      t.timestamps
    end

    add_index(:city_has_self_generated_result_types, :city_id)
    add_index(:city_has_self_generated_result_types, :action_result_type_id, :name => 'chshrt_index_on_action_result_type_id')

  end


  def down
    remove_index(:city_has_self_generated_result_types, :city_id)
    remove_index(:city_has_self_generated_result_types, :name => 'chshrt_index_on_action_result_type_id')

    drop_table(:city_has_self_generated_result_types)
  end
end
