class CityAffiliationWinner < ActiveRecord::Base
  belongs_to :city
  belongs_to :affiliation

  # attr_accessible :city_id, :city, :affiliation_id, :affiliation
end
