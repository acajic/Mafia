class UsersController < ApplicationController
  include ApipieParams::User

  # before_filter :confirm_authorization, :except => [:new, :create]

  RESOURCE = 'User'


  resource_description do
    short "When you register, you become a #{RESOURCE}."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "#{RESOURCE.pluralize()} get created when a person completes a registration. In theory, one person should have one account. So, every registered person should correspond to one #{RESOURCE} object."
  end

  # GET /users
  # GET /users.
  api :GET, '/users', "Query #{RESOURCE.pluralize()}."
  description "Query #{RESOURCE.pluralize()}."
  param_group :auth_required, ApipieParams::Auth
  param :username, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose names contain this string will be returned."
  param :email, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose emails contain this string will be returned."
  param :default_app_role_ids, Array, of: Integer, :required=> false, :desc => "Only if #{RESOURCE}'s default app role id corresponds to one of the ids specified in this array, the #{RESOURCE} will be returned. Example:
  exposemafia.com:3000/users?default_app_role_ids[]=3&default_app_role_ids[]=2"
  param :app_role_ids, Array, of: Integer, :required=> false, :desc => "Only if #{RESOURCE}'s current app role id corresponds to one of the ids specified in this array, the #{RESOURCE} will be returned. Example:
  exposemafia.com:3000/users?app_role_ids[]=3&app_role_ids[]=2"
  param :email_confirmed, ['true', 'false'], :required => false, :desc => "Filter based on whether the email has been confirmed or not."
  param :created_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created after this timestamp will be returned."
  param :created_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created before this timestamp will be returned."
  param :updated_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were updated after this timestamp will be returned."
  param :updated_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were updated before this timestamp will be returned."
  param :page_index, Integer, :required => false, :desc => "Page index."
  param :page_size, Integer, :required => false, :desc => "Page size."
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization) }
  def index
    @users = User.all

    unless params[:username].nil? || params[:username].empty?
      @users = @users.where("username LIKE '%#{params[:username]}%'")
    end

    unless params[:email].nil? || params[:email].empty?
      @users = @users.where("email LIKE '%#{params[:email]}%'")
    end

    unless params[:default_app_role_ids].nil?
      @users = @users.where(:default_app_role_id => params[:app_role_ids])
    end


    unless params[:email_confirmed].nil? || params[:email_confirmed].empty?
      @users = @users.where(:email_confirmed => params[:email_confirmed].downcase == 'true')
    end

    unless params[:created_at_min].nil? || params[:created_at_min].empty?
      @users = @users.where('created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].nil? || params[:created_at_max].empty?
      @users = @users.where('created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    unless params[:updated_at_min].nil? || params[:updated_at_min].empty?
      @users = @users.where('updated_at >= ?', Time.at(params[:updated_at_min].to_i()).to_datetime())
    end

    unless params[:updated_at_max].nil? || params[:updated_at_max].empty?
      @users = @users.where('updated_at <= ?', Time.at(params[:updated_at_max].to_i()).to_datetime())
    end


    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      @users = @users.order('users.id DESC').limit(page_size).offset(page_size*page_index)
    end



    unless params[:app_role_ids].nil?
      @users = @users.to_a()
      @users.keep_if { |user|
        params[:app_role_ids].include?(user.app_role().id.to_s())
      }
    end


    if @authorized_user.app_permissions.any? { |app_permission| app_permission.id == AppPermission::ADMIN_READ }
      render json: @users, User::JSON_OPTION_SHOW_ALL => true
    else
      render json: @users
    end

  end

  before_filter(:only => :me) { |controller| controller.send(:confirm_authorization) }
  api :GET, '/users/me', "Get #{RESOURCE} object representing myself."
  description "Get #{RESOURCE} object representing myself. (#{RESOURCE} is identified based on auth token)."
  param_group :auth_required, ApipieParams::Auth
  def me
    @authorized_user.reload()
    # user_me_hash = @authorized_user.as_json()

    # user_me_hash[:auth_token] = @authorized_user.auth_token


    render json: @authorized_user, User::JSON_OPTION_USER_ID => @authorized_user.id
  end

  # GET /users/1
  # GET /users/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization) }
  api :GET, '/users/:user_id', "Get a #{RESOURCE} by id."
  description "Get a #{RESOURCE} by id."
  param_group :auth_required, ApipieParams::Auth
  param :user_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  def show
    @user = User.find(params[:id])

    if @authorized_user.app_permissions.any? {|perm| perm.id == AppPermission::ADMIN_READ}
      render json: @user, User::JSON_OPTION_SHOW_ALL => true
    else
      render json: @user
    end

  end

  # GET /users/new
  # GET /users/new.json
  api :GET, '/users/new', "Get a template for a new #{RESOURCE}."
  description "Get a blank new #{RESOURCE}."
  def new
    @user = User.new

    render json: @user
  end


  before_filter(:only => :edit) { |controller| controller.send(:confirm_authorization) }
  # GET /users/1/edit
  api :GET, '/users/:user_id/edit', "Get a #{RESOURCE} for editting."
  description "Get a #{RESOURCE} for editting."
  param_group :auth_required, ApipieParams::Auth
  param :user_id, Integer, :required => true, :desc => "A #{RESOURCE} id. #{RESOURCE} can only get their own data."
  def edit
    unless @authorized_user.id == params[:id]
      head :unauthorized
      return false
    end

    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  api :POST, '/users', "Create a new #{RESOURCE}."
  description "Create a new #{RESOURCE}."
  param_group :new_user, ApipieParams::User
  def create
    user_init_hash = params.require(:user)
    user_init_hash.permit(:username, :password, :email)
    @user = User.new(user_init_hash)

    app_role = InitialAppRole.app_role_for_email(@user.email)
    if app_role.nil?
      render json: "Unacceptable email #{@user.email}. This kind of email is not white-listed for registering.", :status => :unprocessable_entity
      return false
    end

    should_send_email_confirmation = false
    if Mafia::Application.config.require_email_verification
      should_send_email_confirmation = true
    else
      @user.email_confirmed = true
      @user.auth_token = AuthToken.create(:user => @user)
      @user.auth_tokens << @user.auth_token
    end

    if @user.save()
      if should_send_email_confirmation
        InfoMailer.send_email_confirmation_mail(@user)
      end
      render json: @user, status: :created, location: @user, User::JSON_OPTION_USER_ID => @user.id
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET /users/confrim_email
  api :GET, '/users/confrim_email', "Confirm email address after registration."
  description "Confirm email address after registration. On success, a redirect to 'http://exposemafia.com/email_confirmation/:email_confirmation_code' is returned. The client will then automatically try to exchange the email confirmation code for auth token."
  param :email_confirmation_code, String, :required => true, :desc => "A confirmation code that was sent via email."
  def confirm_email
    @user = User.where(:email_confirmation_code => params.require(:email_confirmation_code)).first
    if @user.nil?
      head :unauthorized
      return false
    end

    @user.email_confirmed = true

    if @user.save
      default_client_host = InfoMailer::CLIENT_HOST_CITIES

      redirect_to(default_client_host + '/email_confirmation/' + @user.email_confirmation_code)
    else
      render json: @user.errors, status: :unprocessable_entity
    end


  end


  # GET /users/1/resend_confirmation_email
  before_filter(:only => :resend_confirmation_email) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  api :GET, '/users/:user_id/resend_confirmation_email', "[ADMIN] Resend confirmation email."
  description "[ADMIN] Resend confirmation email."
  param :user_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  show false
  def resend_confirmation_email
    user_id = params.require(:id)
    user = User.find(user_id)


    user.email_confirmed = false
    user.email_confirmation_code_exchanged = false
    user.save()
    InfoMailer.send_email_confirmation_mail(user)

    render json: user, User::JSON_OPTION_SHOW_ALL => true, :status => :ok
  end

  # POST /users/forgot_password
  api :POST, '/users/forgot_password', "Request password renewal."
  description "Request password renewal."
  param :email, String, :required => true, :desc => "Email address of registered user. An email will be sent to that address so that the owner of that address can confirm that they want their password renewed."
  def forgot_password
    email = params.require(:email)
    user = User.where(:email => email).first()
    if user.nil?
      render json: "No user with email '#{email}'", :status => :unprocessable_entity
      return false
    end

    user.email_confirmation_code = nil
    user.email_confirmation_code_exchanged = false

    if user.save()
      InfoMailer.confirm_user_forgot_password(user)
      render json: {}, :status => :created
    else
      render json: user.errors, :status => :unprocessable_entity
    end


  end


  # GET /users/confirm_forgot_password?email_confirmation_code={email_confirmation_code}
  api :GET, '/users/confirm_forgot_password', "Confirm password renewal."
  description "Confirm password renewal."
  param :email_confirmation_code, String, :required => true, :desc => "Confirmation code that was sent via email asking the address owner whether they indeed want to renew their password."
  def confirm_forgot_password
    email_confirmation_code = params.require(:email_confirmation_code)

    user = User.where(:email_confirmation_code => email_confirmation_code).first()
    if user.nil?
      render json: "Email confirmation code '#{email_confirmation_code}' not found.", :status => :unprocessable_entity
      return false
    end


    if user.email_confirmation_code_exchanged
      AuthToken.where(:user_id => user.id).destroy_all()
      render json: "Email confirmation code '#{email_confirmation_code}' has already been used. Deleting all existing sessions for this user.", :status => :unprocessable_entity
      return false
    end

    default_client_host = InfoMailer::CLIENT_HOST_CITIES
    if user.email_confirmation_code_exchanged
      redirect_to(default_client_host)
      return false
    end


    password = ('000' + rand(10000).to_s())[-4, 4]
    user.password = password
    user.hashed_password = Static::PasswordUtility.generate_hashed_password(password, user.password_salt)


    if user.save()
      InfoMailer.send_password_to_user_after_reset(user, user.password)

      redirect_to(default_client_host + '/email_confirmation/' + user.email_confirmation_code)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end



  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization) }
  # PUT /users/1
  # PUT /users/1.json
  api :PUT, '/users/:user_id', "Update a #{RESOURCE}."
  description "Update a #{RESOURCE}. Eample: #{ApipieParams::User::UPDATE_USER_DESC}"
  param_group :auth_required, ApipieParams::Auth
  param :user_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  param_group :update_user, ApipieParams::User
  def update
    permission_admin_write = @authorized_user.app_permissions.any? {|perm| perm.id == AppPermission::ADMIN_WRITE}

    if @authorized_user.id != params[:id].to_i() && !permission_admin_write
      render json:'You cannot update user that is not you.', status: :unauthorized
      return false
    end


    logger.info("users/update params: #{params}")

    params_user = params.require(:user)


    @user = User.find(params[:id])
    if @user.nil?
      render json: "User with id #{params[:id]} does not exist", :status => :unprocessable_entity
      return false
    end
    logger.info("Updating User #{@user.as_json()}")

    if !permission_admin_write || @user.id == @authorized_user.id
      @user = User.authenticate(@user.username, params_user[:password])
      unless @user
        render json:'Wrong current password.', status: :unauthorized
        return false
      end
    end

    params_for_update = params_user.permit(:email, :new_password, :repeat_new_password)
    if permission_admin_write && @user.app_role().id != AppRole::SUPER_ADMIN
      params_for_update[:email_confirmed] = params_user[:email_confirmed]
      params_for_update[:email_confirmation_code_exchanged] = params_user[:email_confirmation_code_exchanged]
    end

    if params_user[:new_password].nil? || params_user[:new_password].empty?

    else
      if params_user[:new_password] != params_user[:repeat_new_password]
        render json:'New password and repeated new password don\'t match.', status: :unprocessable_entity
        return false
      else
        params_for_update[:password] = params_user[:new_password]
        params_for_update[:hashed_password] = Static::PasswordUtility.generate_hashed_password(params_for_update[:password], @user.password_salt)
      end
    end

    if permission_admin_write
      if params_user[:default_app_role] && params_user[:default_app_role][:id]
        if @user.default_app_role_id != AppRole::SUPER_ADMIN
          params_for_update[:default_app_role_id] = params_user[:default_app_role][:id]
        end
      end
    end

    params_user_preference = params_user[:user_preference]

    success = true
    ActiveRecord::Base.transaction {
      logger.info("Inside transaction User #{@user.as_json()}")

      success = @user.update_attributes(params_for_update.permit(:username, :email, :hashed_password, :email_confirmed, :email_confirmation_code_exchanged, :default_app_role_id))
      logger.info("Success: #{success}. User updated #{@user.as_json()}")
      if params_user_preference
        success = success && @user.user_preference.update_attributes(params_user_preference)
        logger.info("User preferences updated #{@user.as_json()}")
      end
    }

    if success
      if permission_admin_write
        render json: @user, status: :ok, User::JSON_OPTION_SHOW_ALL => true
      else
        render json: @user, status: :ok
      end

    else
      logger.info("User Errors: #{@user.errors}. User Preference Errors: #{@user.user_preference.errors}")
      errors = @user.errors
      if @user.user_preference
        @user.user_preference.errors.full_messages.each do |msg|
          errors.add_to_base("Preference Error: #{msg}")
        end
      end
      render json: errors, status: :unprocessable_entity
    end

  end


  # DELETE /users/1
  # DELETE /users/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization) }
  api :DELETE, '/users/:user_id', "Delete a #{RESOURCE}."
  description "Delete a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :password, String, :required => true, :desc => "For an important action like this, user password must be submitted."
  def destroy
    user_id = params.require(:id)

    user = User.find(user_id)
    if user.nil?
      head :no_content
      return false
    end


    if @authorized_user.app_permissions.any? {|perm| perm.id == AppPermission::ADMIN_WRITE} && @authorized_user.id != user.id
      user.destroy()
      head :no_content
      return true
    end

    authenticated_user = User.authenticate(@authorized_user.username, params[:password])
    unless authenticated_user
      head :unauthorized
      return false
    end


    if @authorized_user.id == user.id && authenticated_user.id == user.id
      user.destroy()
      head :no_content
      return true
    else
      head :unauthorized
      return false
    end

  end

  api :GET, '/users/allowed_email_patterns', "Get all allowed email patterns for user registration."
  description "Get all allowed email patterns for user registration."
  def allowed_email_patterns
    render json: InitialAppRole.where('email_pattern IS NOT NULL').map { |initial_app_role| initial_app_role.email_pattern}, status: :ok
  end

  api :GET, '/users/app_roles', "Get all possible app roles."
  description "Get all possible app roles."
  def app_roles
    render json: AppRole.all
  end

end
