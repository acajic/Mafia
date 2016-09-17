class CreateGamePurchases < ActiveRecord::Migration
  def up
    create_table :game_purchases do |t|
      t.integer :payment_log_id
      t.integer :user_id
      t.string :user_email
      t.integer :city_id
      t.string :city_name
      t.datetime :city_started_at
      t.timestamps
    end
    add_index :game_purchases, :payment_log_id
    add_index :game_purchases, :city_id
    add_index :game_purchases, :user_id
  end


  def down
    remove_index :game_purchases, :payment_log_id
    remove_index :game_purchases, :city_id
    remove_index :game_purchases, :user_id
    drop_table :game_purchases
  end
end
