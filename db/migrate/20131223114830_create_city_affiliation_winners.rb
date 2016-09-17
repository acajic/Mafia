class CreateCityAffiliationWinners < ActiveRecord::Migration


  def up
    create_table :city_affiliation_winners do |t|
      t.integer :city_id
      t.integer :affiliation_id
      t.timestamps
    end

    add_index(:city_affiliation_winners, :city_id)
    add_index(:city_affiliation_winners, :affiliation_id)

  end


  def down
    remove_index(:city_affiliation_winners, :city_id)
    remove_index(:city_affiliation_winners, :affiliation_id)

    drop_table(:city_affiliation_winners)
  end
end
