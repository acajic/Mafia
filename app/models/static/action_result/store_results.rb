class Static::ActionResult::StoreResults
  def self.prepare_for_db(results, current_day, action_result_type)

    Rails.logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())
    Rails.logger.info('MANUAL LOG - results count: ' + results.count().to_s() + '; current day: ' + current_day.to_json())

    action_result_new_hash_array = []
    results.each { |action_result_hash|
      action_result_hash[:result_json] = action_result_hash[:result].nil? ? nil : action_result_hash[:result].to_json()
      action_result_hash[:day_id] = current_day.nil? ? nil : current_day.id

      if action_result_type
        action_result_type.action_result_will_be_created_based_on_hash(action_result_hash)
      end
      action_result_new_hash_array << action_result_hash.except(:result)
    }
    action_result_new_hash_array
  end

  def self.store_results(results_hash, current_day)
    action_result_new_hash_array = []
    results_hash.each_pair { |action_result_type_class, action_result_hash_array|
      action_result_type = action_result_type_class.first()
      action_result_new_hash_array.concat(self.prepare_for_db(action_result_hash_array, current_day, action_result_type))
    }
    ::ActionResult.create!(action_result_new_hash_array)
  end

end