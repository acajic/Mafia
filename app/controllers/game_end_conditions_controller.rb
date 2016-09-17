class GameEndConditionsController < ApplicationController

  RESOURCE = 'Game End Condition'

  resource_description do
    short "What are the conditions that indicate that a game is over?"
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "What are the conditions that indicate that a game is over?"
  end

  api :GET, '/game_end_conditions', "Get all possible #{RESOURCE.pluralize()}."
  description "Get all possible #{RESOURCE.pluralize()}."
  def index
    render json: GameEndCondition.all
  end
end
