class Affiliation < ActiveRecord::Base
  has_many :roles

  # attr_accessible :name

  CITIZENS = 1
  MAFIA = 2

  before_create :before_creation

  def before_creation
    self.name = 'Affiliation' # implement concrete name in subclass
  end

  # this method exists in order to decouple:
  # 1) determining the end of the game (GameEndConditions),
  # 2) determining which affiliations won and which lost.
  # This enables inclusion of new affiliations in the game.
  # For example: GameEndCondition::CitizensVsMafia reports that the game ended and
  # it automatically knows which affiliation won between Citizens and Mafia.
  # But it will NOT know whether some third affiliation won or lost.
  def is_winner(city)
    # implement in subclass like Affiliation::Citizens or Affiliation::Mafia
  end

  def as_json(options={})
    {
        :id => self.id,
        :name => self.name
    }
  end

end
