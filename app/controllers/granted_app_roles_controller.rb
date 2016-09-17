class GrantedAppRolesController < ApplicationController

  # GET /granted_app_roles
  # GET /granted_app_roles.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def index
    @granted_app_roles = GrantedAppRole.includes(:user).all

    unless params[:email].nil? || params[:email].empty?
      @granted_app_roles = @granted_app_roles.where("users.email LIKE '%#{params[:email]}%'")
    end

    unless params[:username].nil? || params[:username].empty?
      @granted_app_roles = @granted_app_roles.where("users.username LIKE '%#{params[:username]}%'")
    end

    unless params[:description].nil? || params[:description].empty?
      @granted_app_roles = @granted_app_roles.where("granted_app_roles.description LIKE '%#{params[:description]}%'")
    end

    unless params[:expiration_date_min].nil? || params[:expiration_date_min].empty?
      @granted_app_roles = @granted_app_roles.where('granted_app_roles.expiration_date >= ?', Time.at(params[:expiration_date_min].to_i()).to_datetime())
    end

    unless params[:expiration_date_max].nil? || params[:expiration_date_max].empty?
      @granted_app_roles = @granted_app_roles.where('granted_app_roles.expiration_date <= ?', Time.at(params[:expiration_date_max].to_i()).to_datetime())
    end

    unless params[:created_at_min].nil? || params[:created_at_min].empty?
      @granted_app_roles = @granted_app_roles.where('granted_app_roles.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].nil? || params[:created_at_max].empty?
      @granted_app_roles = @granted_app_roles.where('granted_app_roles.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      @granted_app_roles = @granted_app_roles.limit(page_size).offset(page_size*page_index)
    end

    render json: @granted_app_roles
  end

  # GET /granted_app_roles/1
  # GET /granted_app_roles/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def show
    granted_app_role = GrantedAppRole.find(params.require(:id))
    render json: granted_app_role
  end


  # POST /granted_app_roles
  # POST /granted_app_roles.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def create
    granted_app_role_hash = params.require(:granted_app_role)

    granted_app_role_hash = GrantedAppRole.init_hash(granted_app_role_hash)

    granted_app_role = GrantedAppRole.new(granted_app_role_hash)

    if granted_app_role.save()
      render json: granted_app_role, :status => :created, :location => granted_app_role
    else
      render json: granted_app_role.errors, status: :unprocessable_entity
    end
  end



  # PUT /granted_app_roles/1
  # PUT /granted_app_roles/1.json
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def update
    granted_app_role = GrantedAppRole.find(params.require(:id))

    granted_app_role_hash = params.require(:granted_app_role)

    granted_app_role_hash = GrantedAppRole.init_hash(granted_app_role_hash)



    if granted_app_role.update_attributes(granted_app_role_hash)
      render json: granted_app_role, :status => :ok, :location => granted_app_role
    else
      render json: granted_app_role.errors, status: :unprocessable_entity
    end
  end



  # GET /granted_app_roles/new
  # GET /granted_app_roles/new.json
  before_filter(:only => :new) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def new
    new_granted_app_role = GrantedAppRole.new()
    new_granted_app_role.app_role = AppRole.find(AppRole::GAME_CREATOR)
    render json: new_granted_app_role
  end

  # DELETE /granted_app_roles/1
  # DELETE /granted_app_roles/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def destroy
    granted_app_role = GrantedAppRole.find(params.require(:id))

    granted_app_role.destroy()

    head :no_content
  end



end
