class CreateDayCycles < ActiveRecord::Migration
  def up
    create_table :day_cycles do |t|
      t.integer :city_id
      t.integer :day_start
      t.integer :night_start
      t.timestamps
    end

    add_index(:day_cycles, :city_id)
  end

  def down
    remove_index(:day_cycles, :city_id)
    drop_table(:day_cycles)
  end
end
