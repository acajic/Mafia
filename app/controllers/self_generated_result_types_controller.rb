class SelfGeneratedResultTypesController < ApplicationController

  RESOURCE = 'Self Generated Result Type'

  resource_description do
    short "Information that gets generated for every player but its creation is not initiated by any specific action."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "Information that gets generated for every player but its creation is not initiated by any specific action. For example, ActionResultType::Residents is a #{RESOURCE} that informs each player about who is alive and who is dead after every important moment in the course of a game."
  end

  api :GET, '/self_generated_result_types', "Get all #{RESOURCE.pluralize()}."
  description "Get all #{RESOURCE.pluralize()}."
  def index
    render json: ActionResultType.where(:is_self_generated => true)
  end
end
