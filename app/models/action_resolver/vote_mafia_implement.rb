class ActionResolver::VoteMafiaImplement < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # valid vote mafia implement

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if valid_results_hash[ActionResultType::VoteMafia].nil?
      return
    end

    # 1) implement mafia kill
    success = implement(valid_results_hash) # private method

    # /valid vote mafia implement
  end

  def set_ordinal
    self.ordinal = 930
  end

  private

  def implement(valid_results_hash)
    if valid_results_hash[ActionResultType::VoteMafia].nil?
      return false
    end


    valid_result_hash = valid_results_hash[ActionResultType::VoteMafia][0]

    success = valid_result_hash[:result][ActionResultType::VoteMafia::KEY_SUCCESS]
    unless success
      return false
    end

    target_id = valid_result_hash[:result][ActionResultType::VoteMafia::KEY_TARGET_ID]
    if target_id > 0
      resident_to_execute = Resident.find(target_id)
      unless resident_to_execute.alive
        return false
      end
      resident_to_execute.alive = false
      resident_to_execute.died_at = Time.now.utc
      resident_to_execute.save
      return true
    end
  end
end