class CityHasSelfGeneratedResultType < ActiveRecord::Base
  belongs_to :city
  belongs_to :action_result_type

  # attr_accessible :city_id, :city, :self_generated_result_type_id, :self_generated_result_type
end