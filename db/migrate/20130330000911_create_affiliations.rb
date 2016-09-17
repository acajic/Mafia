class CreateAffiliations < ActiveRecord::Migration
  def change
    create_table :affiliations do |t|
      t.string :type
      t.string :name
      t.timestamps
    end

  end
end
