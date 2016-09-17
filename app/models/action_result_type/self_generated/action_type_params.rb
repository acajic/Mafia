class ActionResultType::SelfGenerated::ActionTypeParams < ActionResultType::SelfGenerated

  KEY_ACTION_TYPES_PARAMS = 'action_types_params'


  def before_creating
    self.name = 'Action Type Params'
    self.is_self_generated = true
    self.trigger_id = Trigger::BOTH
    self.description = 'Residents know at all times the state of action type parameters (e.g. how many times they can still use a certain action)'
  end

  def self.self_generated_results(city, day, trigger_id)

    action_results = nil

    latest_day_id = city.action_results.where(:action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS).maximum(:day_id)

    if latest_day_id.nil?
      action_results = self.create_genuine_results(city)
    else
      yesterdays_action_results = ActionResult.where(:day_id => latest_day_id, :action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS).order('created_at DESC').to_a()
      yesterdays_action_results.uniq! { |action_result|
        comparing_string = action_result.city_id.to_s() + "#" + action_result.day_id.to_s() + "#" + action_result.resident_id.to_s()
        comparing_string
      }
      action_results = yesterdays_action_results.dup().map { |action_result|
        self.self_generated_result_hash(action_result.city_id, action_result.resident_id, action_result.result[KEY_ACTION_TYPES_PARAMS])
      }
    end

    action_results

  end


  def self.create_genuine_results(city)
    default_action_type_params_per_role_action_type = self.default_action_type_params_per_role_action_type(city)

    resident_role_action_type_params_per_resident_per_role_per_action_type = self.resident_role_action_type_params_per_resident_per_role_per_action_type(city)


    self_generated_results = []

    residents = Resident.includes(:city => {:city_has_roles => {:role => :action_types}}).where(:city_id => city.id)

    residents.each { |resident|
      action_type_params_result = self.action_type_params_result(resident, resident_role_action_type_params_per_resident_per_role_per_action_type, default_action_type_params_per_role_action_type)

      self_generated_results << self.self_generated_result_hash(city.id, resident.id, action_type_params_result)
    }

    self_generated_results
  end

  def self.default_action_type_params_per_role_action_type(city)
    default_action_type_params_per_role_action_type = {}

    resident_role_action_type_params_records = ResidentRoleActionTypeParamsModel.includes(:resident).where("residents.city_id" => city.id)
    resident_role_action_type_params_records_per_role_per_action_type = {}
    resident_role_action_type_params_records.each { |resident_role_action_type_params_record|
      unless resident_role_action_type_params_records_per_role_per_action_type.has_key?(resident_role_action_type_params_record.role_id)
        resident_role_action_type_params_records_per_role_per_action_type[resident_role_action_type_params_record.role_id] = {}
      end
      unless resident_role_action_type_params_records_per_role_per_action_type[resident_role_action_type_params_record.role_id].has_key?(resident_role_action_type_params_record.action_type_id)
        resident_role_action_type_params_records_per_role_per_action_type[resident_role_action_type_params_record.role_id][resident_role_action_type_params_record.action_type_id] = []
      end
      resident_role_action_type_params_records_per_role_per_action_type[resident_role_action_type_params_record.role_id][resident_role_action_type_params_record.action_type_id] << resident_role_action_type_params_record.original_action_type_params_hash
    }

    role_has_action_type_records = RoleHasActionType.where(:role_id => city.city_has_roles.map { |city_has_role| city_has_role.role_id}).all
    role_has_action_type_per_role_per_action_type = {}
    role_has_action_type_records.each { |role_has_action_type|
      unless role_has_action_type_per_role_per_action_type.has_key?(role_has_action_type.role_id)
        role_has_action_type_per_role_per_action_type[role_has_action_type.role_id] = {}
      end
      unless role_has_action_type_per_role_per_action_type[role_has_action_type.role_id].has_key?(role_has_action_type.action_type_id)
        role_has_action_type_per_role_per_action_type[role_has_action_type.role_id][role_has_action_type.action_type_id] = []
      end
      role_has_action_type_per_role_per_action_type[role_has_action_type.role_id][role_has_action_type.action_type_id] << role_has_action_type.action_type_params
    }

    city.city_has_roles.each { |city_has_role|
      city_has_role.role.action_types.each { |action_type|
        unless default_action_type_params_per_role_action_type.has_key?(city_has_role.role_id)
          default_action_type_params_per_role_action_type[city_has_role.role_id] = {}
        end
        action_type_params_hashes = nil
        if resident_role_action_type_params_records_per_role_per_action_type.has_key?(city_has_role.role_id)
          if resident_role_action_type_params_records_per_role_per_action_type[city_has_role.role_id].has_key?(action_type.id)
            action_type_params_hashes = resident_role_action_type_params_records_per_role_per_action_type[city_has_role.role_id][action_type.id]
          end
        end
        if action_type_params_hashes.nil?
          action_type_params_hashes = role_has_action_type_per_role_per_action_type[city_has_role.role_id][action_type.id]
        end
        default_action_type_params_per_role_action_type[city_has_role.role_id][action_type.id] = action_type_params_hashes
      }
    }
    default_action_type_params_per_role_action_type
  end

  def self.resident_role_action_type_params_per_resident_per_role_per_action_type(city)
    resident_role_action_type_params_records = ResidentRoleActionTypeParamsModel.includes(:resident).where("residents.city_id" => city.id).all
    resident_role_action_type_params_per_resident_per_role_per_action_type = {}
    resident_role_action_type_params_records.each { |resident_role_action_type_params_record|
      unless resident_role_action_type_params_per_resident_per_role_per_action_type.has_key?(resident_role_action_type_params_record.resident_id)
        resident_role_action_type_params_per_resident_per_role_per_action_type[resident_role_action_type_params_record.resident_id] = {}
      end
      unless resident_role_action_type_params_per_resident_per_role_per_action_type[resident_role_action_type_params_record.resident_id].has_key?(resident_role_action_type_params_record.role_id)
        resident_role_action_type_params_per_resident_per_role_per_action_type[resident_role_action_type_params_record.resident_id][resident_role_action_type_params_record.role_id] = {}
      end

      resident_role_action_type_params_per_resident_per_role_per_action_type[resident_role_action_type_params_record.resident_id][resident_role_action_type_params_record.role_id][resident_role_action_type_params_record.action_type_id] = resident_role_action_type_params_record.action_type_params_hash
    }
    resident_role_action_type_params_per_resident_per_role_per_action_type
  end



  def self.action_type_params_result(resident, resident_role_action_type_params_per_resident_per_role_per_action_type, default_action_type_params_per_role_action_type)
    action_type_params_result = {}

    city_has_unique_roles = resident.city.city_has_roles.uniq { |city_has_role| city_has_role.role_id }
    city_has_unique_roles.each { |city_has_role|
      city_has_role.role.action_types.each { |action_type|
        action_type_params_hash = nil
        if resident_role_action_type_params_per_resident_per_role_per_action_type.has_key?(resident.id)
          if resident_role_action_type_params_per_resident_per_role_per_action_type[resident.id].has_key?(city_has_role.role_id)
            action_type_params_hash = resident_role_action_type_params_per_resident_per_role_per_action_type[resident.id][city_has_role.role_id][action_type.id]
          end
        end

        if action_type_params_hash.nil?
          action_type_params_hash = default_action_type_params_per_role_action_type[city_has_role.role_id][action_type.id].sample
        end

        if action_type_params_hash.nil? || action_type_params_hash.empty?
          next
        end

        role_id_string = city_has_role.role_id.to_s()
        unless action_type_params_result.has_key?(role_id_string)
          action_type_params_result[role_id_string] = {}
        end
        action_type_id_string = action_type.id.to_s()
        action_type_params_result[role_id_string][action_type_id_string] = action_type_params_hash
      }
    }
    action_type_params_result
  end

  def self.self_generated_result_hash(city_id, resident_id, action_type_params_result)
    {
       :action => nil,
       :action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS,
       :city_id => city_id,
       :resident_id => resident_id,
       :role_id => nil,
       :result => {KEY_ACTION_TYPES_PARAMS => action_type_params_result},
       :is_automatically_generated => true
    }
  end


end