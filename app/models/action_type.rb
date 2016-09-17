require 'json'

class ActionType < ActiveRecord::Base

  belongs_to :trigger
  belongs_to :action_result_type
  has_many :role_has_action_types, :inverse_of => :action_type
  has_many :roles, :through => :has_action_types
  has_many :actions, :inverse_of => :action_type

  attr_readonly :default_params

  before_create :before_creation

  VOTE = 1
  PROTECT = 2
  INVESTIGATE = 3
  VOTE_MAFIA = 4
  SHERIFF_IDENTITIES = 5
  TELLER_VOTES = 6
  TERRORIST_BOMB = 7
  MAFIA_MEMBERS = 8
  RESIDENTS = 9
  JOURNALIST = 10
  DEPUTY_IDENTITIES = 11
  ELDER_VOTE = 12
  INITIATE_REVIVAL = 13
  REVIVE = 14
  FORGER_VOTE = 15


  def before_creation
    self.trigger_id = Trigger::NIGHT_START
    @default_params = action_type_params()
    self.default_params_json = self.default_params.to_json()
  end

  def default_params
    if @default_params == nil
      @default_params = JSON.parse(self.default_params_json)
    end
    @default_params
  end

  def params_valid(action_type_params)
    true
  end

  def action_valid?(action, action_type_params_per_resident_role_action_type)
    role_has_action_type = action.role.action_types.include?(action.action_type)
    assuming_true_role = action.resident.role_id == action.role_id
    action_requires_alive_posting = action.resident_alive || !self.require_alive_posting
    action_requires_alive_processing = action.resident.alive || !self.require_alive_processing

    role_has_action_type && assuming_true_role && action_requires_alive_posting && action_requires_alive_processing
  end

  def action_type_params
    {} # default implementation is empty hash
  end

  def generate_automatic_action_hashes(city, day_id, trigger_id, last_action_type_params_result_per_resident)
    [] # by default return empty array
  end

  #returns array of ActionResult init hashes
  def create_valid_action_results(actions, city)
    []
  end

  #returns array of ActionResult init hashes
  def create_void_action_results(actions, city)
    []
  end

  def start_valid_async_execution(action)
    # override in subclass if necessary
  end

  def stop_valid_async_execution(action)
    # override in subclass if necessary
  end

  def start_void_async_execution(action)
    # override in subclass if necessary
  end

  def stop_void_async_execution(action)
    # override in subclass if necessary
  end

  def as_json(options={})
    {
        :id => self.id,
        :name => self.name,
        :trigger => self.trigger,
        :is_single_required => self.is_single_required,
        :action_type_params => self.action_type_params,
        :action_result_type => self.action_result_type,
        :can_submit_manually => self.can_submit_manually
    }
  end

end
