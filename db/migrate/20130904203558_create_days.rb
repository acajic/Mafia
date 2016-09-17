class CreateDays < ActiveRecord::Migration
  def up
    create_table :days do |t|
      t.integer :city_id
      t.integer :number
      t.timestamps
    end

    add_index(:days, :city_id)
  end

  def down
    remove_index(:days, :city_id)
    drop_table(:days)
  end
end
