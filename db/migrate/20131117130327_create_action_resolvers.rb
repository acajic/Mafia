class CreateActionResolvers < ActiveRecord::Migration
  def change
    create_table :action_resolvers do |t|
      t.string :type
      t.integer :ordinal
      t.timestamps
    end


  end

end
