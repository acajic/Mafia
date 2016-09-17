class ActionType::TellerVotes < ActionType


  PARAM_LIFETIME_ACTIONS_COUNT = 'number_of_actions_available'

  TRIGGER_ID = Trigger::NIGHT_START

  def before_creation
    super
    self.trigger_id = TRIGGER_ID
    self.require_alive_processing = true # resident must be alive at the time an action of this type comes to processing, otherwise: action is void
    @default_params = action_type_params()
    self.default_params_json = self.default_params.to_json()

    self.name = 'Count Votes'
    self.action_result_type_id = ActionResultType::TELLER_VOTES
  end

  def action_type_params
    {
        PARAM_LIFETIME_ACTIONS_COUNT => -1 # infinite
    }
  end

  def params_valid(action_type_params)
    if action_type_params.nil?
      return true
    end

    actions_count_param = action_type_params[PARAM_LIFETIME_ACTIONS_COUNT]
    actions_count_param.is_a?(Numeric)
  end

  def action_valid?(action, action_type_params_per_resident_role_action_type)
    actions_available(action, action_type_params_per_resident_role_action_type)
  end


  def generate_automatic_action_hashes(city, day_id, trigger_id, last_action_type_params_result_per_resident)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    automatic_action_hashes = []
    if trigger_id == self.trigger_id

      resident_role_action_type_params = ResidentRoleActionTypeParamsModel.includes(:resident).where('residents.city_id' => city.id).where(:action_type_id => self.id).all
      resident_role_action_type_params_hashes_per_resident_per_role = {}
      resident_role_action_type_params.each { |resident_role_action_type_params_record|
        unless resident_role_action_type_params_hashes_per_resident_per_role.has_key?(resident_role_action_type_params_record.resident_id)
          resident_role_action_type_params_hashes_per_resident_per_role[resident_role_action_type_params_record.resident_id] = {}
        end

        resident_role_action_type_params_hashes_per_resident_per_role[resident_role_action_type_params_record.resident_id][resident_role_action_type_params_record.role_id] = resident_role_action_type_params_record
      }

      city_has_roles = city.city_has_roles.includes(:role => :role_has_action_types).to_a()

      city.residents.each { |resident|
        city_has_roles.each { |city_has_role|
          if city_has_role.role.role_has_action_types.map { |role_has_action_type| role_has_action_type.action_type_id }.include?(self.id)
            # in this block we isolated only sensible role<->action_type combinations

            # first try reading action_type_params from the last action_type_params_result
            action_type_params_hash = nil
            if last_action_type_params_result_per_resident[resident]
              action_type_params_hash = last_action_type_params_result_per_resident[resident].result[ActionResultType::SelfGenerated::ActionTypeParams::KEY_ACTION_TYPES_PARAMS][city_has_role.role_id.to_s()][self.id.to_s()]
            end



            # if not found there, check actual data in ResidentRoleActionTypeParamsModel
            if action_type_params_hash.nil?
              res_rol_a_type_params = nil
              if resident_role_action_type_params_hashes_per_resident_per_role[resident.id].nil?
                resident_role_action_type_params_hashes_per_resident_per_role[resident.id] = {}
              else
                res_rol_a_type_params = resident_role_action_type_params_hashes_per_resident_per_role[resident.id][city_has_role.role_id]
              end
              if res_rol_a_type_params.nil?
                res_rol_a_type_params = ResidentRoleActionTypeParamsModel.create(:resident => resident, :role => city_has_role.role, :action_type => self)
                resident_role_action_type_params_hashes_per_resident_per_role[resident.id][city_has_role.role_id] = res_rol_a_type_params
              end


              action_type_params_hash = res_rol_a_type_params.action_type_params_hash
            end

            if action_type_params_hash[PARAM_LIFETIME_ACTIONS_COUNT] < 0
              automatic_action_hashes << {:resident_id => resident.id, :role_id => city_has_role.role_id, :action_type_id => self.id, :day_id => day_id, :input_json => nil}
            end
          end
        }
      }

    end
    automatic_action_hashes
  end



  def default_action_type_params_hashes_per_role_id(city)
    default_action_type_params_hashes_per_role_id = {}

=begin
    resident_role_action_types_params = ResidentRoleActionTypeParams.includes(:resident).where('residents.city_id' => city.id).where(:action_type_id => self.id)
    resident_role_action_types_params.each { |resident_role_action_type_params|
      unless default_action_type_params_hashes_per_role_id.has_key?(resident_role_action_type_params.role_id)
        default_action_type_params_hashes_per_role_id[resident_role_action_type_params.role_id] = []
      end
      default_action_type_params_hashes_per_role_id[resident_role_action_type_params.role_id] << resident_role_action_type_params.original_action_type_params_hash
    }
=end

    role_action_types_params = RoleHasActionType.where(:role_id => city.city_has_roles.map { |city_has_role|
      city_has_role.role_id
    }, :action_type_id => self.id)

    role_action_types_params.each { |role_action_type_params|
      if default_action_type_params_hashes_per_role_id[role_action_type_params.role_id].nil?
        default_action_type_params_hashes_per_role_id[role_action_type_params.role_id] = [role_action_type_params.action_type_params]
      end
    }

    default_action_type_params_hashes_per_role_id
  end

  def create_valid_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    process_actions(actions)
  end

  def create_void_action_results(actions, city)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    process_actions(actions)
  end

  private

  def process_actions(actions)
    if actions.nil? || actions.empty?
      return nil
    end

    actions_per_resident = Action.latest_action_per_resident(actions)

    action_results = []
    actions_per_resident.each_pair { |resident, action|
      # commented code prevents teller from receiving results to void TellerVotes actions submitted while dead
      #unless resident.alive
      #  next
      #end

      result_hash = {
          self.action_result_type.class::KEY_SUCCESS => true
      }

      action_results << {:action => action,
                         :action_result_type_id => self.action_result_type_id,
                         :city_id => resident.city_id,
                         :resident_id => resident.id,
                         :role_id => action.role_id,
                         # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                         :result => result_hash,
                         :is_automatically_generated => true}
    }

    action_results #return array of ActionResult init hashes
  end


  def actions_available(action, action_type_params_per_resident_role_action_type)
    resident_role_action_type_params = nil
    if action_type_params_per_resident_role_action_type[action.resident_id].nil? ||
        action_type_params_per_resident_role_action_type[action.resident_id][action.role_id].nil? ||
        action_type_params_per_resident_role_action_type[action.resident_id][action.role_id][action.action_type_id].nil?
      resident_role_action_type_params = ResidentRoleActionTypeParamsModel.create(:resident_id => action.resident_id, :role_id => action.role_id, :action_type_id => action.action_type_id)
    else
      resident_role_action_type_params = action_type_params_per_resident_role_action_type[action.resident_id][action.role_id][action.action_type_id]
    end


    if resident_role_action_type_params.action_type_params_hash[PARAM_LIFETIME_ACTIONS_COUNT] < 0
      return true # negative value interpreted as infinite
    end

    actions_available = resident_role_action_type_params.action_type_params_hash[PARAM_LIFETIME_ACTIONS_COUNT] > 0
    actions_available
  end

end