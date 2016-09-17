class RolePicksController < ApplicationController

  # GET /role_picks
  # GET /role_picks.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def index
    role_picks = RolePick.includes(:user, :city, :role).all

    unless params[:username].blank?
      role_picks = role_picks.where("users.username LIKE '%#{params[:username]}%'")
    end

    unless params[:user_email].blank?
      role_picks = role_picks.where("users.email LIKE '%#{params[:user_email]}%'")
    end

    unless params[:city_name].blank?
      role_picks = role_picks.where("cities.name LIKE '%#{params[:city_name]}%'")
    end

    if params[:role_ids]
      role_picks = role_picks.where(:role_id => params[:role_ids])
    end

    unless params[:city_started_at_min].nil? || params[:city_started_at_min].empty?
      @actions = @actions.where('role_picks.city_started_at >= ?', Time.at(params[:city_started_at_min].to_i()).to_datetime())
    end

    unless params[:city_started_at_max].nil? || params[:city_started_at_max].empty?
      @actions = @actions.where('role_picks.city_started_at <= ?', Time.at(params[:city_started_at_max].to_i()).to_datetime())
    end


    role_picks.order!('role_picks.id DESC')

    if params[:page_index] && params[:page_size]
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      role_picks = role_picks.limit(page_size).offset(page_size*page_index)
    end

    render json: role_picks
  end

  # GET /role_picks/me
  # GET /role_picks/me.json
  before_filter(:only => :me) { |controller| controller.send(:confirm_authorization) }
  def me
    role_picks = @authorized_user.role_picks

    role_picks.order!('role_picks.id DESC')

    if params[:page_index] && params[:page_size]
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      role_picks = role_picks.limit(page_size).offset(page_size*page_index)
    end

    render json: role_picks
  end


  # GET /role_picks/1
  # GET /role_picks/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization) }
  def show
    role_pick = RolePick.find(params.require(:id))

    render json: role_pick
  end

  # GET /role_picks/new
  # GET /role_picks/new.json
  before_filter(:only => :new) { |controller| controller.send(:confirm_authorization) }
  def new
    new_role_pick = RolePick.new()

    render json: new_role_pick
  end


  # POST /role_picks/me
  # POST /role_picks/me.json
  before_filter(:only => :create_my_role_pick) { |controller| controller.send(:confirm_authorization) }
  def create_my_role_pick
    role_pick_hash = params.require(:role_pick)

    city = City.find(role_pick_hash.require(:city_id))

    if city.started_at
      render json: 'Cannot submit a Role Pick on a game that has already started.', :status => :unprocessable_entity
      return false
    end

    role_pick_hash = role_pick_hash.permit(:city_id, :role_id)
    role_pick_hash[:user_id] = @authorized_user.id
    role_pick_hash[:city_name] = city.name


    role_pick = RolePick.new(role_pick_hash)

    if role_pick.save()
      render json: role_pick, :status => :created
    else
      render json: role_pick.errors, :status => :unprocessable_entity
      return false
    end

  end


  # PUT /role_picks/1
  # PUT /role_picks/1.json
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization) }
  def update
    role_pick = RolePick.find(params.require(:id))

    if role_pick.user_id != @authorized_user.id
      render json: 'Cannot access a Role Pick that does not belong to you.', :status => :unauthorized
      return false
    end

    if role_pick.update_attributes(params.require(:role_pick))
      render json: role_pick, :status => :ok
    else
      render json: role_pick.errors, :status => :unprocessable_entity
    end
  end


  # DELETE /role_picks/1
  # DELETE /role_picks/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization) }
  def destroy
    role_pick = RolePick.find(params.require(:id))

    if role_pick.user_id != @authorized_user.id
      render json: 'Cannot delete a Role Pick that does not belong to you.', :status => :unauthorized
      return false
    end

    role_pick.destroy()
    head :no_content
  end

end
