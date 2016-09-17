class AuthTokensController < ApplicationController

  RESOURCE = 'Auth Token'

  LOGIN_DESC = '
  {
      "username": "AndrijaCajic",
      "password": "yourPasswordHere"
  }
'

  resource_description do
    name 'Authentication'
    short "Login, Logout and stuff."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "Using these endpoints users can authenticate and acquire auth_token that they submit in their request for all endpoints that require authentication."
  end



  # GET /auth_tokens
  # GET /auth_tokens.json
  def index
    # @auth_tokens = AuthToken.all

    head :forbidden
    # render json: @auth_tokens
  end

# GET /auth_tokens/1
# GET /auth_tokens/1.json
  def show
    head :forbidden
    #render json: @auth_token
  end

# GET /auth_tokens/new
# GET /auth_tokens/new.json
  def new
    head :forbidden

    # @auth_token = AuthToken.new

    # render json: @auth_token
  end

# GET /auth_tokens/1/edit
  def edit
    head :forbidden
    #@auth_token = AuthToken.find(params[:id])
  end

# POST /auth_tokens
# POST /auth_tokens.json
  api :POST, '/login', "Exchange credentials for an #{RESOURCE}."
  description "Exchange credentials for an #{RESOURCE}. Example parameters:
#{LOGIN_DESC}
"
  param :username, String, :required => true, :desc => "User's username"
  param :password, String, :required => true, :desc => "User's password. (Password are not stored anywhere in plaintext)."
  def create
    authorized_user = User.authenticate(params[:username], params[:password], params[:identifier_url])
    if authorized_user == false
      render json:'Wrong credentials', status: :unauthorized
      return false
    end

    unless authorized_user.email_confirmed
      render json:'Email not confirmed', status: :unauthorized
      return false
    end

    if authorized_user
      render json: authorized_user, User::JSON_OPTION_USER_ID => authorized_user.id
    else
      head :unauthorized
    end

    #@auth_token = AuthToken.new(params[:auth_token])
    # respond_to do |format|
    #  if @auth_token.save
    #   render json: @auth_token, status: :created, location: @auth_token
    # else
    #   render json: @auth_token.errors, status: :unprocessable_entity
    # end
    #end
  end

  # GET /impersonate_login/1
  # GET /impersonate_login/1.json
  before_filter(:only => :create_auth_token_for_user) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  api :GET, '/impersonate_login/:user_id', "Obtain an #{RESOURCE} for any specific user without knowing their password."
  description "Obtain an #{RESOURCE} for any specific user without knowing their password."
  param :user_id, Integer, :required => true, :desc => "User's id."
  show false
  def create_auth_token_for_user
    user = User.find(params.require(:user_id))
    user.auth_token = AuthToken.create(:user => user)
    user.auth_tokens << user.auth_token
    user.save()

    user_hash = user.as_json()
    user_hash[:auth_token] = user.auth_token

    render json: user_hash
  end


# POST /auth_tokens/exchange_email_confirmation_code
  api :POST, '/exchange_email_confirmation_code', "Exchange email confirmation code for an #{RESOURCE}."
  description "Exchange email confirmation code for an #{RESOURCE}. It can be done only once per confirmation code. If this same endpoint was tried the second time with the same confirmation code, all auth tokens for that user get invalidated and user has to login again using credentials."
  param :email_confirmation_code, String, :required => true, :desc => "Email confirmation code"
  def exchange_email_confirmation_code
    email_confirmation_code = params.require(:email_confirmation_code)
    user = User.where(:email_confirmation_code => email_confirmation_code).first
    if user.nil?
      render json:'No user with specified email_confirmation_code', status: :unprocessable_entity
      return false
    end

    if user.email_confirmation_code_exchanged
      # someone tried to exchange email confirmation code for auth token for the SECOND time
      # either if this time the request comes from a perpetrator or an an actual user, they won't be handed an auth token
      # in any case all existing auth tokens will be invalidated
      AuthToken.where(:user_id => user.id).destroy_all()
      render json:'Multiple requests for exchanging email_confirmation_code for auth_token. Invalidating all existing auth tokens for this user.', status: :forbidden
      return false
    else
      user.email_confirmation_code_exchanged = true
      user.auth_token = AuthToken.create(:user => user)
      user.auth_tokens << user.auth_token
      user.save()
    end

    authorized_user_hash = user.as_json()
    authorized_user_hash[:auth_token] = user.auth_token
    if user
      render json: authorized_user_hash
    else
      head :unauthorized
    end

  end

# PUT /auth_tokens/1
# PUT /auth_tokens/1.json
  def update
    head :forbidden
    #   @auth_token = AuthToken.find(params[:id])
    #
    #   if @auth_token.update_attributes(params[:auth_token])
    #    head :no_content
    # else
    #  render json : @auth_token.errors, status : :unprocessable_entity
    # end
  end

# DELETE /auth_tokens/1
# DELETE /auth_tokens/1.json
  def destroy
    head :forbidden
  end

  # DELETE /auth_tokens/invalidate_auth_token
  # DELETE /auth_tokens/invalidate_auth_token.json
  before_filter(:only => :invalidate_auth_token) { |controller| controller.send(:confirm_authorization) }
  api :DELETE, '/logout', "Invalidate the #{RESOURCE} that is passed as a parameter."
  description "Invalidate the #{RESOURCE} that is passed as a parameter."
  param_group :auth_required, ApipieParams::Auth
  def invalidate_auth_token
    auth_token_string = params.require(:auth_token)

    @@auth_tokens_cache_array.delete(auth_token_string)
    @@auth_tokens_cache_hash.delete(auth_token_string)
    auth_token = AuthToken.where(:token_string => auth_token_string).first
    auth_token.destroy()

    head :no_content
  end

end
