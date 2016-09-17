module Module::City::Queries
  def unprocessed_actions(day)
    # commented line takes into account only actions of current day
    # self.actions.includes([:day, :action_type, {role: :role_has_action_types}]).where("actions.is_processed = FALSE").where("days.number" => day.number).all
    # following line takes into consideration all unprocessed actions
    self.actions.includes([:day, :action_type, {role: :role_has_action_types}]).where('actions.is_processed' => false)
  end

  def valid_unprocessed_actions(day)
    # commented line takes into account only actions of current day
    # self.actions.includes([:day, :action_type, {resident: {role: :action_types}}]).where("days.number" => day.number).where("actions.is_processed = FALSE").where("actions.role_id = roles.id").where("actions.action_type_id = action_types_roles.id").all
    # following line takes into consideration all unprocessed actions
    # self.actions.joins([:day, :action_type, {resident: {role: :action_types}}]).where("actions.is_processed = FALSE").where("actions.role_id = roles.id").where("actions.action_type_id = action_types_roles.id").uniq.all

    action_type_params_per_resident_role_action_type = self.action_type_params_per_resident_role_action_type()

    self.actions.includes([:day, :action_type, {resident: {role: :action_types}}]).where('actions.is_processed' => false).select { |some_action|
      is_true_role = some_action.role_id == some_action.resident.role_id
      has_action_type = some_action.resident.role.action_types.any? { |some_action_type| some_action_type.id == some_action.action_type_id}


      is_true_role && has_action_type && some_action.action_valid?(action_type_params_per_resident_role_action_type)
    }
  end


  def action_type_params_per_resident_role_action_type
    city_rratp_models = ResidentRoleActionTypeParamsModel.includes(:resident => :city).where('cities.id' => self.id)
    action_type_params_per_resident_role_action_type = {}
    city_rratp_models.each { |rratp|
      if action_type_params_per_resident_role_action_type[rratp.resident_id].nil?
        action_type_params_per_resident_role_action_type[rratp.resident_id] = {}
      end

      if action_type_params_per_resident_role_action_type[rratp.resident_id][rratp.role_id].nil?
        action_type_params_per_resident_role_action_type[rratp.resident_id][rratp.role_id] = {}
      end

      action_type_params_per_resident_role_action_type[rratp.resident_id][rratp.role_id][rratp.action_type_id] = rratp
    }
    action_type_params_per_resident_role_action_type
  end
end