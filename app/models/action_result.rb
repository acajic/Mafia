require_dependency('module/action_result/initializer')

class ActionResult < ActiveRecord::Base
  extend Module::ActionResult::Initializer

  scope :genuine, -> { where(is_automatically_generated: true) }

  belongs_to :action
  belongs_to :city
  belongs_to :day
  belongs_to :resident
  belongs_to :role
  belongs_to :action_result_type

  accepts_nested_attributes_for :action, :city, :day, :resident, :role, :action_result_type

  attr_accessor :result

  before_save :before_saving

  def before_saving
    unless @result == nil
      self.result_json = @result.to_json()
    end
  end

  def result
    if @result == nil && !self.result_json.nil? && self.result_json != nil.to_json()
      @result = JSON.parse(self.result_json)
    end
    @result
  end


  JSON_OPTION_SHOW_ALL = 'show_all'

  def as_json(options={})
    action_result_hash =
    {
        :id => self.id,
        :city_id => self.city_id,
        :city_name => self.city ? self.city.name : nil,
        :action_id => self.action_id,
        :action_type_id => self.action.nil? ? nil : self.action.action_type_id,
        :action_result_type => self.action_result_type,
        :result => self.result,
        :result_json => self.result_json,
        :day_number => self.day.nil? ? nil : self.day.number,
        :day_id => self.day.nil? ? nil : self.day.id,
        # :resident_id => self.resident_id,
        # :role_id => self.role_id,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }

    unless options[JSON_OPTION_SHOW_ALL].nil?
      action_result_hash[:resident_id] = self.resident_id
      action_result_hash[:resident_username] = self.resident ? (self.resident.user ? self.resident.user.username : nil) : nil
      action_result_hash[:is_automatically_generated] = self.is_automatically_generated
      action_result_hash[:deleted] = self.deleted
    end

    action_result_hash
  end




  def self.observer_action_results(city_id, day_number_min = nil, day_number_max = nil)
    city = City.find(city_id)
    action_results_per_action_type = self.create_and_process_observer_single_required_actions_if_necessary(city)


    Static::ActionResult::StoreResults.store_results(action_results_per_action_type, nil) # method declared in Module::StoreResults


    action_results = ActionResult.where(:city_id => city_id).where('resident_id IS NULL')
    if day_number_min && day_number_max
      action_results = action_results.joins('LEFT JOIN days ON action_results.day_id = days.id').where('(days.number >= ? AND days.number < ?) OR action_results.day_id IS NULL', day_number_min, day_number_max)
    elsif day_number_min
      action_results = action_results.joins('LEFT JOIN days ON action_results.day_id = days.id').where('days.number >= ? OR action_results.day_id IS NULL', day_number_min)
    elsif day_number_max
      action_results = action_results.joins('LEFT JOIN days ON action_results.day_id = days.id').where('days.number < ? OR action_results.day_id IS NULL', day_number_max)
    end


    action_results = action_results.order('action_results.day_id DESC, action_results.action_result_type_id DESC, action_results.id DESC')
    action_results
  end


  def self.query_action_results(city_id, user_id, role_id, action_type_id = nil, day_number_min = nil, day_number_max = nil)
    resident = Resident.includes(:city).where(:city_id => city_id, :user_id => user_id).first()
    unless resident.city.started_at
      # disable retrieving action results while city has not even started
      return []
    end


    action_results_per_action_type = self.create_and_process_single_required_actions_if_necessary(resident.city, role_id, resident)


    Static::ActionResult::StoreResults.store_results(action_results_per_action_type, nil) # method declared in Module::StoreResults


    # line below commented because it's filtering action results based on role_id
    # action_results = ActionResult.includes([:action, :day, :resident]).where("days.city_id" => city_id).where("action_results.resident_id = ? OR action_results.resident_id IS NULL", resident.id).where("action_results.role_id = ? OR action_results.role_id IS NULL", role_id)
    action_results = ActionResult.joins('LEFT JOIN actions ON action_results.action_id = actions.id').joins('LEFT JOIN residents ON action_results.resident_id = residents.id').where('action_results.city_id = ?', city_id).where('action_results.resident_id = ? OR action_results.resident_id IS NULL', resident.id)

    unless action_type_id.nil?
      action_results = action_results.where('actions.action_type_id' => action_type_id)
    end
    if day_number_min && day_number_max
      action_results = action_results.joins('LEFT JOIN days ON action_results.day_id = days.id').where('(days.number >= ? AND days.number < ?) OR action_results.day_id IS NULL', day_number_min, day_number_max)
    elsif day_number_min
      action_results = action_results.joins('LEFT JOIN days ON action_results.day_id = days.id').where('days.number >= ? OR action_results.day_id IS NULL', day_number_min)
    elsif day_number_max
      action_results = action_results.joins('LEFT JOIN days ON action_results.day_id = days.id').where('days.number < ? OR action_results.day_id IS NULL', day_number_max)
    end


    action_results = action_results.order('action_results.day_id DESC, action_results.action_result_type_id DESC, action_results.id DESC')
    filtered_action_results = unique_action_results(action_results)
    filtered_action_results.keep_if { |filtered_action_result|
      !filtered_action_result.deleted # filter deleted action results in the end, because otherwise, when resident deletes a certain action result, the one that was overriden up to that point will start showing again
    }
    filtered_action_results
  end


  def self.create_and_process_single_required_actions_if_necessary(city, role_id, resident)
    city_has_roles = CityHasRole.includes(:role => :action_types).where(:city_id => city).where('action_types.is_single_required' => true).to_a()

    # BEGIN create single required actions


    # fetch existing action results and sort them by action result type
    action_results_per_action_result_type = {}
    if resident
      action_results = ActionResult.includes(:action, :action_result_type).where('action_results.resident_id = ? OR action_results.resident_id IS NULL', resident.id).where(:city_id => city.id).to_a()
    else
      action_results = ActionResult.includes(:action, :action_result_type).where('action_results.resident_id IS NULL').where(:city_id => city.id).to_a()
    end

    action_results.each { |action_result|
      unless action_results_per_action_result_type.has_key?(action_result.action_result_type)
        action_results_per_action_result_type[action_result.action_result_type] = []
      end

      action_results_per_action_result_type[action_result.action_result_type] << action_result
    }


    action_initializers = []

    single_required_action_types = []
    # fetch all single required action types
    city_has_roles.each { |city_has_role|
      city_has_role.role.action_types.each { |action_type| # when fetching city_has_roles, only single required action_types were included
        unless single_required_action_types.include?(action_type)
          single_required_action_types << action_type
        end
      }
    }

    # delegate creation of single required actions to each action type
    # each individual action type will decide whether it will actually create new actions or not, depending on existing action results of corresponding type (action_results_per_action_result_type[action_type.action_result_class.name])
    single_required_action_types.each { |action_type|
      action_hash = action_type.single_required_action_initializer(resident, role_id, action_results_per_action_result_type[action_type.action_result_type])
      unless action_hash.nil?
        action_initializers << action_hash
      end

    }

    # create single required Actions using array of action initializers
    actions_per_action_type = {}
    actions = Action.create(action_initializers)
    actions.each { |action|
      unless actions_per_action_type.has_key?(action.action_type)
        actions_per_action_type[action.action_type] = []
      end
      actions_per_action_type[action.action_type] << action
      action
    }

    # END create single required actions

    action_type_params_per_resident_role_action_type = city.action_type_params_per_resident_role_action_type()

    action_results_per_action_result_type_class = {}

    actions_per_action_type.each_pair { |action_type, actions|
      if action_type.action_result_type.nil?
        logger.error('MANUAL LOG - single required action does not have its own action result type')
      end

      unless action_results_per_action_result_type_class.has_key?(action_type)
        action_results_per_action_result_type_class[action_type.action_result_type.class] = []
      end

      actions.each { |action|
        if action.action_valid?(action_type_params_per_resident_role_action_type)
          action_results_per_action_result_type_class[action_type.action_result_type.class].concat(action_type.create_valid_action_results([action], city))
        else
          action_results_per_action_result_type_class[action_type.action_result_type.class].concat(action_type.create_void_action_results([action], city))
        end
      }

    }

    action_results_per_action_result_type_class
  end


  def self.create_and_process_observer_single_required_actions_if_necessary(city)
    # BEGIN create single required actions


    # fetch existing action results and sort them by action result type
    action_results_per_action_result_type = {}
    action_results = ActionResult.includes(:action).where('action_results.resident_id IS NULL').where(:city_id => city.id)

    action_results.each { |action_result|
      unless action_results_per_action_result_type.has_key?(action_result.action_result_type)
        action_results_per_action_result_type[action_result.action_result_type] = []
      end

      action_results_per_action_result_type[action_result.action_result_type] << action_result
    }


    action_initializers = []

    single_required_action_types = []
    # fetch all single required action types

    role = Role.find(Role::CITIZEN)
    single_required_action_types = role.action_types.select {|action_type| action_type.is_single_required}


    # delegate creation of single required actions to each action type
    # each individual action type will decide whether it will actually create new actions or not, depending on existing action results of corresponding type (action_results_per_action_result_type[action_type.action_result_class.name])
    single_required_action_types.each { |action_type|
      action_hash = action_type.single_required_action_initializer(nil, role.id, action_results_per_action_result_type[action_type.action_result_type])
      unless action_hash.nil?
        action_initializers << action_hash
      end

    }

    # create single required Actions using array of action initializers
    actions_per_action_type = {}
    actions = Action.create(action_initializers)
    actions.each { |action|
      unless actions_per_action_type.has_key?(action.action_type)
        actions_per_action_type[action.action_type] = []
      end
      actions_per_action_type[action.action_type] << action
      action
    }

    # END create single required actions

    action_type_params_per_resident_role_action_type = city.action_type_params_per_resident_role_action_type()

    action_results_per_action_type = {}

    actions_per_action_type.each_pair { |action_type, actions|
      unless action_results_per_action_type.has_key?(action_type)
        action_results_per_action_type[action_type] = []
      end

      actions.each { |action|
        if action.action_valid?(action_type_params_per_resident_role_action_type)
          action_results_per_action_type[action_type].concat(action_type.create_valid_action_results([action], city))
        else
          action_results_per_action_type[action_type].concat(action_type.create_void_action_results([action], city))
        end
      }

    }

    action_results_per_action_type
  end



  # if action results are matching, they should never both be shown to the end user
  def matching(action_result1, action_result2)
    (action_result1.role_id == action_result2.role_id || action_result1.role_id.nil? || action_result2.role_id.nil?) &&
        action_result1.class == action_result2.class &&
        action_result1.day_id == action_result2.day_id
  end


  private


  def self.unique_action_results(action_results)
    # keeps only latest action_results per role_id, action_type_id, day combination
    filtered_action_results = []

    if action_results.nil?
      return filtered_action_results
    end

    action_results.each { |action_result|
      match = nil
      filtered_action_results.each { |unique_action_result|
        if is_match(action_result, unique_action_result)
          match = unique_action_result
          break
        else
          next
        end

      }
      if match == nil
        filtered_action_results << action_result
      else
=begin
        if action_result.created_at > match.created_at
          filtered_action_results.delete(match)
          filtered_action_results << action_result
        end
=end
      end
    }
    filtered_action_results
  end

  def self.is_match(action_result1, action_result2)
    if action_result1.action_result_type == action_result2.action_result_type
      return action_result1.action_result_type.matching(action_result1, action_result2)
    else
      return false
    end
  end




end