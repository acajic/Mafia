class CreateAppPermissions < ActiveRecord::Migration
  def change
    create_table :app_permissions do |t|
      t.string :name
      t.timestamps
    end
  end

  PARTICIPATE = 1
  CREATE_GAMES = 2

end
