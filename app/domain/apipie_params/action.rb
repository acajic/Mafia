module ApipieParams::Action
  extend Apipie::DSL::Concern


  CREATE_ACTION_DESC = '
  {
      action_instance: {
          city_id: 3,
          role_id: 6,
          action_type_id: 1,
          day_id: 31,
          input: {
              target_id: 25
          }
      },
      auth_token: "5764b40be8726d3f4e4f6c0cda526a9fccc4c4774fb36f7f4840b4ed217a999b"
  }'


  def_param_group :create_action do
    param :action, Hash, :desc => 'Action', :required => true do
      param :city_id, Integer, :desc => 'City id (for what game is the action submitted).', :required => true
      param :role_id, Integer, :desc => 'Role id (under what role does a user submit this action).', :required => true
      param :action_type_id, Integer, :desc => 'Action type id (what action is it).', :required => true
      param :input, Hash, :desc => 'Parameters for the action. For example, if it is a Vote action - Who is the user voting for?.', :required => true
    end

  end


  DELETE_ACTION_DESC = '
  {
      city_id: 3,
      role_id: 6,
      action_type_id: 1,
      auth_token: "5764b40be8726d3f4e4f6c0cda526a9fccc4c4774fb36f7f4840b4ed217a999b",
  }
'

end