class RoleHasActionType < ActiveRecord::Base
  belongs_to :role
  belongs_to :action_type

  # attr_accessible :role, :role_id, :action_type, :action_type_id, :action_type_params_json
  attr_readonly :action_type_params

  before_create :before_creation

  def before_creation
    if @action_type_params == nil
      @action_type_params = self.action_type.default_params
    end
    self.action_type_params_json = @action_type_params.to_json()
  end

  def action_type_params
    if @action_type_params.nil?
      @action_type_params = JSON.parse(self.action_type_params_json)
    end

    @action_type_params
  end

  def as_json(options={})
    {
        :role_id => self.role_id,
        :action_type_id => self.action_type_id,
        :action_type_params => self.action_type_params
    }
  end
end
