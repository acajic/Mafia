class RolesController < ApplicationController

  RESOURCE = 'Role'

  resource_description do
    short "Game roles like Citizen, Doctor, Detective, Mafia, ..."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "Game roles like Citizen, Doctor, Detective, Mafia, ..."
  end

  api :GET, '/roles', "Get all possible #{RESOURCE.pluralize()}."
  description "Get all possible #{RESOURCE.pluralize()}."
  def index
    render json: Role.all
  end
end
