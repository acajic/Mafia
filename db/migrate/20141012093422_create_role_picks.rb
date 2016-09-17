class CreateRolePicks < ActiveRecord::Migration
  def up
    create_table :role_picks do |t|
      t.integer :user_id
      t.integer :city_id
      t.string :city_name
      t.datetime :city_started_at
      t.integer :role_id
      t.timestamps
    end
    add_index :role_picks, :user_id
    add_index :role_picks, :city_id
    add_index :role_picks, :role_id
  end


  def down
    remove_index :role_picks, :user_id
    remove_index :role_picks, :city_id
    remove_index :role_picks, :role_id
    drop_table :role_picks
  end
end
