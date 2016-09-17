class ActionResultTypesController < ApplicationController

  RESOURCE = 'Action Result Type'

  resource_description do
    short "All action results are of a certain type."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "Here you can see all of the possible action result types."
  end

  api :GET, '/action_result_types', "Get all possible #{RESOURCE.pluralize()}."
  description "Get all possible #{RESOURCE.pluralize()}."
  def index
    render json: ActionResultType.all
  end

end
