module ApipieParams::ActionResult
  extend Apipie::DSL::Concern

  ACTION_RESULT_DESC = '
  {
      action_result: {
          city_id: 3,
          role_id: null,
          action_result_type: {
              id: 8
          },
          day_id: 31,
          result: {
              target_ids: [
                  30
              ],
              success: true
          }
      },
      auth_token: "5764b40be8726d3f4e4f6c0cda526a9fccc4c4774fb36f7f4840b4ed217a999b"
  }
'

  def_param_group :create_action_result do
    param :action_result, Hash, :desc => 'Action Result', :required => true do
      param :city_id, Integer, :desc => 'City id (for what game is the action result).', :required => true
      param :role_id, Integer, :desc => 'Role id (under what role will user be able to see this result).', :required => false
      param :action_result_type, Hash, :desc => 'Action result type.', :required => true
      param :result, Hash, :desc => 'Actual parameters of the action result. For example, if it is a Vote action - Who is the user that got voted out. If it is a terrorist bomb action, what are the players that got killed?', :required => true
    end

  end

end