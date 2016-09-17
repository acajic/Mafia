class CreateGameEndConditions < ActiveRecord::Migration
  def change
    create_table :game_end_conditions do |t|
      t.string :name
      t.text :description
      t.string :type
      t.timestamps
    end

  end
end