class CreateCityHasGameEndConditions < ActiveRecord::Migration
  def up
    create_table :city_has_game_end_conditions do |t|
      t.integer :city_id
      t.integer :game_end_condition_id
      t.timestamps
    end

    add_index(:city_has_game_end_conditions, :city_id)
    add_index(:city_has_game_end_conditions, :game_end_condition_id)


  end

  def down
    remove_index(:city_has_game_end_conditions, :city_id)
    remove_index(:city_has_game_end_conditions, :game_end_condition_id)

    drop_table(:city_has_game_end_conditions)
  end
end
