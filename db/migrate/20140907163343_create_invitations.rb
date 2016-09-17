class CreateInvitations < ActiveRecord::Migration
  def up
    create_table :invitations do |t|
      t.integer :city_id
      t.integer :user_id
      t.timestamps
    end
    add_index(:invitations, :city_id)
    add_index(:invitations, :user_id)
  end

  def down
    remove_index(:invitations, :user_id)
    remove_index(:invitations, :city_id)
    drop_table(:invitations)
  end
end
