class CreateUserPreferences < ActiveRecord::Migration
  def up
    create_table :user_preferences do |t|
      t.integer :user_id
      t.boolean :receive_notifications_when_added_to_game, :default => true
      t.boolean :automatically_join_when_invited, :default => true
      t.timestamps
    end
    add_index(:user_preferences, :user_id)
  end

  def down
    remove_index(:user_preferences, :user_id)
    drop_table(:user_preferences)
  end
end
