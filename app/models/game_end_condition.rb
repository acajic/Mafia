class GameEndCondition < ActiveRecord::Base
  has_many :city_has_game_end_conditions
  has_many :cities, :through => :city_has_game_end_conditions

  CITIZENS_VS_MAfIA = 1

  # attr_accessible :name, :description

  # @@param city [City]
  # @@return [boolean]
  def check_game_end(city)
    # subclass
  end

  def as_json(options={})
    {
        :id => self.id,
        :name => self.name,
        :description => self.description
    }
  end
end
