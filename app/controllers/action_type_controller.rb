class ActionTypeController < ApplicationController

  RESOURCE = 'Action Type'

  resource_description do
    short "All actions are of a certain type."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "Here you can see all of the possible action types."
  end

  api :GET, '/action_type', "Get all possible #{RESOURCE.pluralize()}."
  description "Get all possible #{RESOURCE.pluralize()}."
  def index
    render json: ActionType.all
  end


end
