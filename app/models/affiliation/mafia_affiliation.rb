class Affiliation::MafiaAffiliation < Affiliation

def before_creation
  self.name = 'Mafia'
end

def is_winner(city)
  residents = city.residents

  city_id = nil

  affiliation_mafia_count = 0
  affiliation_citizens_count = 0

  residents.each { |resident|
    if city_id == nil
      city_id = resident.city_id
    end

    unless resident.alive?
      next
    end

    if resident.role.affiliation_id == Affiliation::MAFIA
      affiliation_mafia_count += 1
    end

    if resident.role.affiliation_id == Affiliation::CITIZENS
      affiliation_citizens_count += 1
    end
  }

  if affiliation_mafia_count >= affiliation_citizens_count
    # end game - mafia wins
    CityAffiliationWinner.create(:city_id => city_id, :affiliation_id => Affiliation::MAFIA)
    true
  else
    CityAffiliationLoser.create(:city_id => city_id, :affiliation_id => Affiliation::MAFIA)
    false
  end
end

end