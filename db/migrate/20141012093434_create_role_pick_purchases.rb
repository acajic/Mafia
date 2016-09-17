class CreateRolePickPurchases < ActiveRecord::Migration
  def up
    create_table :role_pick_purchases do |t|
      t.integer :payment_log_id
      t.integer :user_id
      t.string :user_email
      t.integer :role_pick_id
      t.timestamps
    end

    add_index :role_pick_purchases, :payment_log_id
    add_index :role_pick_purchases, :role_pick_id
    add_index :role_pick_purchases, :user_id
  end

  def down
    remove_index :role_pick_purchases, :payment_log_id
    remove_index :role_pick_purchases, :role_pick_id
    remove_index :role_pick_purchases, :user_id
    drop_table :role_pick_purchases
  end
end
