class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :identifier_url
      t.string :hashed_password
      t.string :password_salt
      t.integer :default_app_role_id, :default => 2
      t.boolean :email_confirmed, :default => false
      t.string :email_confirmation_code
      t.boolean :email_confirmation_code_exchanged, :default => false
      t.timestamps
    end
    add_index :users, :identifier_url, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :username, :unique => true
    add_index :users, :default_app_role_id

  end

  def down
    remove_index :users, :identifier_url
    remove_index :users, :username
    remove_index :users, :email
    remove_index :users, :default_app_role_id
    drop_table :users
  end
end
