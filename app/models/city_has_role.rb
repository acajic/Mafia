class CityHasRole < ActiveRecord::Base
  include Module::City::Validator

  belongs_to :city
  belongs_to :role

  # attr_accessible :city_id, :city, :role_id, :role, :action_types_params, :action_types_params_json

  attr_accessor :action_types_params

  before_save :before_saving

  accepts_nested_attributes_for :city
  accepts_nested_attributes_for :role, :update_only => true

  def action_types_params
    if @action_types_params.nil?
      @action_types_params = JSON.parse(self.action_types_params_json)
    end
    @action_types_params
  end


  def before_saving
    if @action_types_params.nil?
      @action_types_params = {}
    end

    self.role.action_types.each { |action_type|
      if @action_types_params[action_type.id.to_s()].nil?
        @action_types_params[action_type.id.to_s()] = action_type.default_params
      end
    }


    self.action_types_params_json = @action_types_params.to_json()
  end


  def as_json(options={})
    {
        :id => self.id,
        :city_id => self.city_id,
        :role => self.role,
        :action_types_params => self.action_types_params
    }
  end

end
