class CreateAuthTokens < ActiveRecord::Migration
  def up
    create_table :auth_tokens do |t|
      t.integer :user_id
      t.string :token_string
      t.datetime :expiration_date
      t.timestamps
    end
    # add_index :auth_tokens, :token_string, :unique => true
    add_index(:auth_tokens, :user_id)
  end

  def down
    # remove_index(:auth_tokens, :token_string)
    remove_index(:auth_tokens, :user_id)

    drop_table(:auth_tokens)
  end
end
