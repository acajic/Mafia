class CreateSubscriptionPurchases < ActiveRecord::Migration
  def up
    create_table :subscription_purchases do |t|
      t.integer :payment_log_id
      t.integer :user_id
      t.string :user_email
      t.integer :subscription_type
      t.datetime :expiration_date
      t.timestamps
    end

    add_index :subscription_purchases, :payment_log_id
    add_index :subscription_purchases, :user_id
  end


  def down
    remove_index :subscription_purchases, :payment_log_id
    remove_index :subscription_purchases, :user_id
    drop_table :subscription_purchases
  end
end
