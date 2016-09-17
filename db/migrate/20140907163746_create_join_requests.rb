class CreateJoinRequests < ActiveRecord::Migration
  def up
    create_table :join_requests do |t|
      t.integer :city_id
      t.integer :user_id
      t.timestamps
    end
    add_index(:join_requests, :city_id)
    add_index(:join_requests, :user_id)
  end

  def down
    remove_index(:join_requests, :user_id)
    remove_index(:join_requests, :city_id)
    drop_table(:join_requests)
  end
end
