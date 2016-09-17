class GameEndCondition::CitizensVsMafia < GameEndCondition

  def check_game_end(city)
    residents = city.residents(true)

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

    if affiliation_mafia_count == 0
      # end game - citizens win
      # CityAffiliationLoser.create(:city_id => city_id, :affiliation_id => Affiliation::MAFIA)
      # CityAffiliationWinner.create(:city_id => city_id, :affiliation_id => Affiliation::CITIZENS)

      logger.info("MANUAL LOG - GAME OVER -  citizensCount #{affiliation_citizens_count}; mafiaCount #{affiliation_mafia_count}")
      true
    elsif affiliation_mafia_count >= affiliation_citizens_count
      # end game - mafia wins
      # CityAffiliationLoser.create(:city_id => city_id, :affiliation_id => Affiliation::CITIZENS)
      # CityAffiliationWinner.create(:city_id => city_id, :affiliation_id => Affiliation::MAFIA)

      logger.info("MANUAL LOG - GAME OVER - citizensCount #{affiliation_citizens_count}; mafiaCount #{affiliation_mafia_count}")
      true
    else

      false
    end
  end
end