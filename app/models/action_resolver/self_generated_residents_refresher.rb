class ActionResolver::SelfGeneratedResidentsRefresher < ActionResolver


  def resolve(valid_results_hash, void_results_hash, city, trigger_id)

    # refresh SelfGenerated::Residents results, insert up-to-date data in :result hash
    # after all of the resolver that do the killings are executed, SelfGenerated::Residents result must be refreshed

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if valid_results_hash[ActionResultType::SelfGenerated::Residents].nil?
      return
    end

    valid_gsr = valid_results_hash[ActionResultType::SelfGenerated::Residents][0]
    city_id = valid_gsr[:city_id]
    city = City.find(city_id)

    refreshed_residents_result_hash = ActionResultType::SelfGenerated::Residents.self_generated_results(city, nil, nil)
    residents_result_hash_per_resident_id = {}
    refreshed_residents_result_hash.each { |residents_result_hash|
      residents_result_hash_per_resident_id[residents_result_hash[:resident_id]] = residents_result_hash
    }

    valid_results_hash[ActionResultType::SelfGenerated::Residents].each { |valid_residents_result| # valid self generated residents result
      refreshed_result_hash = residents_result_hash_per_resident_id[valid_residents_result[:resident_id]]
      valid_residents_result[:result] = refreshed_result_hash[:result]
    }
  end

  def set_ordinal
    self.ordinal = 1200
  end
end