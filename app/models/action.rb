require_dependency("module/action/queries")
require_dependency("module/action/initializer")

class Action < ActiveRecord::Base
  extend Module::Action::Initializer
  include Module::Action::Queries


  # attr_accessible :resident_id, :role_id, :action_type_id, :day_id, :input, :input_json, :day, :is_processed, :resident_alive

  attr_accessor :input

  belongs_to :resident
  delegate :city, :to => :resident
  belongs_to :role
  belongs_to :action_type
  belongs_to :day
  has_many :action_results # if action has an immediate and a delayed effect, then it will produce two action results. One immediately on processing, and the other with X days delay.

  attr_readonly :action_type_params # instance of ResidentRoleActionTypeParams model

  before_create :before_creation
  after_create :after_creation

  before_save :before_saving


  def action_type_params(refresh_bool = false)
    if refresh_bool || @action_type_params == nil
      @action_type_params = ResidentRoleActionTypeParamsModel.for_action(self).first()
      if @action_type_params == nil
        @action_type_params = ResidentRoleActionTypeParamsModel.create(:resident => self.resident, :role => self.role, :action_type => self.action_type)
      end
    end
    @action_type_params
  end

  def action_valid?(action_type_params_per_resident_role_action_type)
    self.action_type.action_valid?(self, action_type_params_per_resident_role_action_type)
  end

  def self.latest_action_per_resident(actions)
    actions_per_resident = {}
    unless actions.nil?
      actions.each { |action|
        if actions_per_resident.has_key?(action.resident)
          old_action = actions_per_resident[action.resident]
          if action.created_at > old_action.created_at
            actions_per_resident[action.resident] = action
          end
        else
          actions_per_resident[action.resident] = action
        end
      }
    end

    actions_per_resident # return
  end

  def self.actions_per_resident(actions)
    actions_per_resident = {}
    unless actions.nil?
      actions.each { |action|
        if actions_per_resident[action.resident].nil?
          actions_per_resident[action.resident] = []
        end
        actions_per_resident[action.resident] << action
      }
    end

    actions_per_resident # return
  end

  def before_creation
    self.resident_alive = self.resident ? self.resident.alive : false
    true
  end

  def after_creation
    self.start_async_action()
  end

  def before_saving
    unless @input == nil
      self.input_json = @input.to_json()
    end
  end

  def input
    if @input == nil && self.input_json != nil
      @input = JSON.parse(self.input_json)
    end
    @input
  end

  def start_async_action
    if self.action_type.trigger_id == Trigger::ASYNC
      action_type_params_per_resident_role_action_type = self.city.action_type_params_per_resident_role_action_type()
      if self.action_valid?(action_type_params_per_resident_role_action_type)
        self.action_type.start_valid_async_execution(self)
      else
        self.action_type.start_void_async_execution(self)
      end
    end
  end

  def stop_async_action
    if self.action_type.trigger_id == Trigger::ASYNC
      action_type_params_per_resident_role_action_type = self.city.action_type_params_per_resident_role_action_type()
      if self.action_valid?(action_type_params_per_resident_role_action_type)
        self.action_type.stop_valid_async_execution(self)
      else
        self.action_type.stop_void_async_execution(self)
      end

    end
  end

  def scheduler_tag
    "#{self.class}#{self.id}"
  end


  def self.cancel_unprocessed_actions(city_id, user_id, role_id = nil, action_type_id = nil, day_number = nil)
    resident = Resident.where(:city_id => city_id, :user_id => user_id).first()
    if resident.nil?
      return
    end

    actions = Action.joins('LEFT JOIN days ON actions.day_id = days.id').where(:resident_id => resident.id, :is_processed => false)
    unless role_id.nil?
      actions = actions.where(:role_id => role_id)
    end
    unless action_type_id.nil?
      actions = actions.where(:action_type_id => action_type_id)
    end
    unless day_number.nil?
      actions = actions.where('days.number = ?', day_number)
    end

    actions.each { |action|
      action.stop_async_action()
    }

    actions.destroy_all()
  end



  def as_json(options={})
    {
        :id => self.id,
        :resident => self.resident.as_json(Resident::JSON_OPTION_SHOW_ALL),
        :role => self.role,
        :action_type => self.action_type,
        :day => self.day,
        :resident_alive => self.resident_alive,
        :is_processed => self.is_processed,
        :input_json => self.input_json,
        :input => self.input,
        :created_at => self.created_at
    }

  end

end
