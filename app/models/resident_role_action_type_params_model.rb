class ResidentRoleActionTypeParamsModel < ActiveRecord::Base
  scope :for_action, ->(action) { where(resident_id: action.resident_id).where(role_id: action.role_id).where(action_type_id: action.action_type_id) }


  belongs_to :resident
  belongs_to :role
  belongs_to :action_type

  # attr_accessible :resident_id, :resident, :role_id, :role, :action_type_id, :action_type, :action_type_params_hash
  attr_accessor :action_type_params_hash, :original_action_type_params_hash

  before_create :before_creation
  before_save :before_saving

  def action_type_params_hash
    if @action_type_params_hash.nil?
      if self.action_type_params_json.nil?
      else
        @action_type_params_hash = JSON.parse(self.action_type_params_json)
      end
    end
    @action_type_params_hash
  end

  def original_action_type_params_hash
    if @original_action_type_params_hash.nil?
      if self.original_action_type_params_json.nil?
      else
        @original_action_type_params_hash = JSON.parse(self.original_action_type_params_json)
      end

    end
    @original_action_type_params_hash
  end

  def before_creation
    if @action_type_params_hash.nil?
      city_has_role_array = CityHasRole.where(:role_id => self.role_id, :city_id => self.resident.city_id).to_a()
      action_type_params_array = city_has_role_array.map { |city_has_role| city_has_role.action_types_params[self.action_type_id.to_s()] }

      @action_type_params_hash = action_type_params_array.sample()
    end

    @original_action_type_params_hash = @action_type_params_hash.dup()

    self.action_type_params_json = @action_type_params_hash.to_json()
    self.original_action_type_params_json = @original_action_type_params_hash.to_json()
  end

  def before_saving
    unless @action_type_params_hash.nil?
      self.action_type_params_json = @action_type_params_hash.to_json()
    end
    unless @original_action_type_params_hash.nil?
      self.original_action_type_params_json = @original_action_type_params_hash.to_json()
    end
  end

  def reset_action_type_params
    self.action_type_params_hash = self.original_action_type_params_hash
    self.save()
  end

  def as_json(options={})
    {
        :resident_id => self.resident_id,
        :role_id => self.role_id,
        :action_type_id => self.action_type_id,
        :action_type_params => self.action_type_params_hash
    }
  end

end
