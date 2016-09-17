class InitialAppRolesController < ApplicationController

  # GET /initial_app_roles
  # GET /initial_app_roles.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def index
    @initial_app_roles = InitialAppRole.all

    unless params[:email].nil? || params[:email].empty?
      @initial_app_roles = @initial_app_roles.where("initial_app_roles.email LIKE '%#{params[:email]}%'")
    end

    unless params[:email_pattern].nil? || params[:email_pattern].empty?
      @initial_app_roles = @initial_app_roles.where("initial_app_roles.email_pattern LIKE '%#{params[:email_pattern]}%'")
    end

    unless params[:description].nil? || params[:description].empty?
      @initial_app_roles = @initial_app_roles.where("initial_app_roles.description LIKE '%#{params[:description]}%'")
    end

    unless params[:created_at_min].nil? || params[:created_at_min].empty?
      @initial_app_roles = @initial_app_roles.where('initial_app_roles.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].nil? || params[:created_at_max].empty?
      @initial_app_roles = @initial_app_roles.where('initial_app_roles.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      @initial_app_roles = @initial_app_roles.limit(page_size).offset(page_size*page_index)
    end

    render json: @initial_app_roles
  end


  # GET /initial_app_roles/1
  # GET /initial_app_roles/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def show
    initial_app_role = InitialAppRole.find(params.require(:id))
    render json: initial_app_role
  end

  # POST /initial_app_roles
  # POST /initial_app_roles.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def create
    params_initial_app_role = params.require(:initial_app_role)

    initial_app_role = InitialAppRole.new(params_initial_app_role.permit(:description, :email, :email_pattern, :priority, :enabled))
    initial_app_role.app_role = AppRole.find(params_initial_app_role.require(:app_role).require(:id))

    if initial_app_role.save()
      render json: initial_app_role, :status => :created, :location => initial_app_role
    else
      render json: initial_app_role.errors, status: :unprocessable_entity
    end
  end

  # PUT /initial_app_roles/1
  # PUT /initial_app_roles/1.json
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def update
    initial_app_role = InitialAppRole.find(params.require(:id))

    params_initial_app_role = params.require(:initial_app_role)

    params_for_update = params_initial_app_role.permit(:description, :email, :email_pattern, :priority, :enabled)
    if params_initial_app_role[:app_role]
      app_role_id = params_initial_app_role[:app_role][:id]
      params_for_update[:app_role_id] = app_role_id
    end

    if initial_app_role.update_attributes(params_for_update)
      render json: initial_app_role, :status => :ok, :location => initial_app_role
    else
      render json: initial_app_role.errors, status: :unprocessable_entity
    end
  end

  # GET /initial_app_roles/new
  # GET /initial_app_roles/new.json
  before_filter(:only => :new) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def new
    render json: InitialAppRole.new()
  end

  # DELETE /initial_app_roles/1
  # DELETE /initial_app_roles/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def destroy
    initial_app_role = InitialAppRole.find(params.require(:id))
    initial_app_role.destroy()

    head :no_content
  end

end
