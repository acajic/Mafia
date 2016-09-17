module ApipieParams::Auth
  extend Apipie::DSL::Concern


  def_param_group :auth_required do
    param :auth_token, String, :desc => 'Auth Token is obtained via /login and destroyed via /logout endpoint.', :required => true
  end

  def_param_group :auth_optional do
    param :auth_token, String, :desc => 'Auth Token is obtained via /login and destroyed via /logout endpoint.', :required => false
  end


end