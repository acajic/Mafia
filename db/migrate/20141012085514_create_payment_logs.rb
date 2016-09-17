class CreatePaymentLogs < ActiveRecord::Migration
  def up
    create_table :payment_logs do |t|
      t.integer :user_id
      t.string :user_email
      t.integer :payment_type_id
      t.decimal :unit_price
      t.integer :quantity
      t.decimal :total_price
      t.text :info_json # any additional information about the payment
      t.boolean :is_payment_valid, :default => true # maybe a payment will be reverted afterwards or cancelled for some other reason
      t.boolean :is_sandbox, :default => true # sandbox payment logs are the ones that were not caused by an actual money transaction, they were created in an artificial way
      t.timestamps
    end
    add_index :payment_logs, :user_id
    add_index :payment_logs, :payment_type_id
    add_index :payment_logs, :user_email
  end

  def down
    remove_index :payment_logs, :user_id
    remove_index :payment_logs, :payment_type_id
    remove_index :payment_logs, :user_email
    drop_table :payment_logs
  end
end
