class ActionResolver::GameOver < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # check if game is over and if it is create ActionResult::GameOver

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless city.started_at
      return
    end

    # city.reload()
    if city.detect_game_end() # Module::City::Starter
      city.stop() # clear scheduler


      affiliations = []
      resident_roles = []
      city.residents.each { |resident|
        resident_hash = resident.as_json()
        resident_hash[:role] = resident.role.as_json()
        resident_roles << resident_hash
        unless affiliations.include?(resident.role.affiliation)
          affiliations << resident.role.affiliation
        end
      }

      winner_affiliations = []
      loser_affiliations = []
      affiliations.each { |affiliation|
        if affiliation.is_winner(city)
          winner_affiliations << affiliation
        else
          loser_affiliations << affiliation
        end
      }

      valid_results_hash[ActionResultType::SelfGenerated::GameOver] = [{
                  :action => nil,
                  :action_result_type_id => ActionResultType::GAME_OVER,
                  :city_id => city.id,
                  :resident_id => nil,
                  :role_id => nil,
                  :result => {ActionResultType::GameOver::KEY_WINNER_AFFILIATIONS => winner_affiliations, ActionResultType::GameOver::KEY_LOSER_AFFILIATIONS => loser_affiliations, ActionResultType::GameOver::KEY_RESIDENT_ROLES => resident_roles},
                  :is_automatically_generated => true
              }]
    else
      # do nothing
    end


    # /check if game is over and if it is create ActionResult::GameOver
  end

  def set_ordinal
    self.ordinal = 10000
  end
end