class ActionResolver::TerroristBombSelfGeneratedResidents < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if valid_results_hash[ActionResultType::TerroristBomb].nil? || valid_results_hash[ActionResultType::SelfGenerated::Residents].nil?
      return
    end

    # 1) implement kills
    implement(valid_results_hash) # private method

    # 2) add to GS Residents
    valid_results_hash[ActionResultType::TerroristBomb].each { |valid_terr_bomb_result|
      target_ids = valid_terr_bomb_result[:result][ActionResultType::TerroristBomb::KEY_TARGET_IDS]
      if target_ids != nil
        valid_results_hash[ActionResultType::SelfGenerated::Residents].each { |valid_sg_residents_result|
          residents = valid_sg_residents_result[:result][ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS]
          residents.each { |resident|
            if target_ids.include?(resident[:id])
              resident.alive = false
            end
          }
        }
      end
    }
  end

  def set_ordinal
    self.ordinal = 950
  end

  private

  def implement(valid_results_hash)
    if valid_results_hash[ActionResultType::TerroristBomb].nil?
      return
    end

    valid_results_hash[ActionResultType::TerroristBomb].each { |valid_result_hash|
      target_ids = valid_result_hash[:result][ActionResultType::TerroristBomb::KEY_TARGET_IDS]
      Resident.where(:id => target_ids).update_all(:alive => false, :died_at => Time.now.utc)
    }

  end
end