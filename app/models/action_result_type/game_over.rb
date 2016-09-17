class ActionResultType::GameOver < ActionResultType

  KEY_WINNER_AFFILIATIONS = "winner_affiliations"
  KEY_LOSER_AFFILIATIONS = "loser_affiliations"
  KEY_RESIDENT_ROLES = "residents_with_roles"

  def before_creating
    self.name = 'Game Over'
  end

end