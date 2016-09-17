class CreateTriggers < ActiveRecord::Migration


  def change
    create_table :triggers do |t|
      t.string :name
      t.text :description
      t.timestamps
    end



  end
end
