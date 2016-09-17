require_dependency("action_result_type/self_generated/residents")

module Module::City::SelfGenerated

  def self_generated_results(day, trigger_id, specific_self_generated_result_type_classes = nil)
    self_generated_results_by_type = {}

    self.self_generated_result_types.where("trigger_id = ? OR trigger_id = ?", trigger_id, Trigger::BOTH).each { |self_generated_result_type|
      unless specific_self_generated_result_type_classes.nil?
        unless specific_self_generated_result_type_classes.include?(self_generated_result_type.class)
          next
        end
      end
      if self_generated_result_type.class.respond_to?(:self_generated_results)
        self_generated_results_by_type[self_generated_result_type.class] = self_generated_result_type.class.self_generated_results(self, day, trigger_id)
      else
        raise "Andro: method 'self_generated_results' should be implemented for any class sublassing ActionResult::SelfGenerated"
      end

    }

    self_generated_results_by_type
  end

end