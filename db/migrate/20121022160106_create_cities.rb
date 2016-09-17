class CreateCities < ActiveRecord::Migration
  def up
    create_table :cities do |t|
      t.string :name
      t.text :description
      t.integer :user_creator_id
      t.boolean :public, :default => true
      t.string :password
      t.string :hashed_password
      t.string :password_salt
      t.boolean :active, :default => false
      t.boolean :paused, :default => false
      t.boolean :paused_during_day, :default => nil
      t.datetime :last_paused_at, :default => nil
      t.datetime :started_at, :default => nil
      t.datetime :finished_at, :default => nil
      t.integer :timezone, :default => 0
      t.datetime :last_accessed_at, :default => nil
      t.timestamps
    end

    add_index(:cities, :user_creator_id)
  end

  def down
    remove_index(:cities, :user_creator_id)
    drop_table(:cities)
  end

end
