class CityHasGameEndCondition < ActiveRecord::Base
  belongs_to :city
  belongs_to :game_end_condition

  # attr_accessible :city_id, :city, :game_end_condition_id, :game_end_condition
end
