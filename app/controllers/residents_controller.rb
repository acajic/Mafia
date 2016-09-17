class ResidentsController < ApplicationController
  include ApipieParams::Resident

  RESOURCE = 'Resident'


  resource_description do
    short "When a user joins a city, they become #{RESOURCE.pluralize()}."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "When a user joins a city, they become #{RESOURCE.pluralize()}. A #{RESOURCE} belongs to one city and to one user."
  end

  # GET /residents
  # GET /residents.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  api :GET, '/residents', "[ADMIN] Query #{RESOURCE.pluralize()}"
  description "[ADMIN] Query #{RESOURCE.pluralize()}"
  param :user_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} with there ids will be returned. Example:
  exposemafia.com:3000/residents?user_ids[]=6&user_ids[]=5"
  param :username, String, :required => false, :desc => "#{RESOURCE.pluralize()} that belong to users whose usernames contain this string."
  param :name, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose names contain this string."
  param :city_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} to at least one of these cities. Example:
  exposemafia.com:3000/residents?city_ids[]=6&city_ids[]=5"
  param :city_name, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose cities' names contain this string."
  param :role_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} whose true game roles are one of the specified. Example:
  exposemafia.com:3000/residents?role_ids[]=2&role_ids[]=3&role_ids[]=4"
  param :saved_role_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} whose saved game roles are one of the specified. Example:
  exposemafia.com:3000/residents?saved_role_ids[]=2&saved_role_ids[]=3&saved_role_ids[]=4"
  param :role_seen, ['true', 'false'], :required => false, :desc => "#{RESOURCE.pluralize()} have logged in into the game at least once. They are the ones who have seen their game role."
  param :alive, ['true', 'false'], :required => false, :desc => "Alive #{RESOURCE.pluralize()}."
  param :died_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that died after this timestamp will be returned."
  param :died_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that died before this timestamp will be returned."
  param :updated_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were updated after this timestamp will be returned."
  param :updated_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were updated before this timestamp will be returned."
  param :page_index, Integer, :required => false, :desc => "Page index."
  param :page_size, Integer, :required => false, :desc => "Page size."
  show false
  def index
    @residents = Resident.joins(:city)
    .joins('LEFT JOIN users ON residents.user_id = users.id')
    .joins('LEFT JOIN roles ON residents.role_id = roles.id')

    unless params[:user_ids].nil?
      @residents = @residents.where(:user_id => params[:user_ids])
    end

    unless params[:username].nil? || params[:username].empty?
      @residents = @residents.where("users.username LIKE '%#{params[:username]}%'")
    end

    unless params[:name].nil? || params[:name].empty?
      @residents = @residents.where("residents.name LIKE '%#{params[:name]}%'")
    end

    unless params[:city_ids].nil?
      @residents = @residents.where(:city_id => params[:city_ids])
    end

    unless params[:city_name].nil? || params[:city_name].empty?
      @residents = @residents.where("cities.name LIKE '%#{params[:city_name]}%'")
    end

    unless params[:role_ids].nil?
      @residents = @residents.where('role_id IN (?) OR role_id IS NULL', params[:role_ids])
    end

    unless params[:saved_role_ids].nil?
      @residents = @residents.where('saved_role_id IN (?) OR saved_role_id IS NULL', params[:saved_role_ids])
    end

    unless params[:role_seen].nil? || params[:role_seen].empty?
      @residents = @residents.where(:role_seen => params[:role_seen].downcase == 'true')
    end

    unless params[:alive].nil? || params[:alive].empty?
      @residents = @residents.where(:alive => params[:alive].downcase == 'true')
    end

    unless params[:died_at_min].nil? || params[:died_at_min].empty?
      @residents = @residents.where('died_at >= ?', Time.at(params[:died_at_min].to_i()).to_datetime())
    end

    unless params[:died_at_max].nil? || params[:died_at_max].empty?
      @residents = @residents.where('died_at <= ?', Time.at(params[:died_at_max].to_i()).to_datetime())
    end

    unless params[:updated_at_min].nil? || params[:updated_at_min].empty?
      @residents = @residents.where('updated_at >= ?', Time.at(params[:updated_at_min].to_i()).to_datetime())
    end

    unless params[:updated_at_max].nil? || params[:updated_at_max].empty?
      @residents = @residents.where('updated_at <= ?', Time.at(params[:updated_at_max].to_i()).to_datetime())
    end

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      @residents = @residents.limit(page_size).offset(page_size*page_index)
    end

    @residents = @residents.all

    resident_hashes = @residents.map { |resident|
      resident_hash = resident.as_json(Resident::JSON_OPTION_SHOW_ALL => true)
      resident_hash
    }

    render(:json => resident_hashes)
  end

  # GET /residents/1
  # GET /residents/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization) }
  api :GET, '/residents/:resident_id', "Show a #{RESOURCE}."
  description "Show a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :resident_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  def show
    @resident = Resident.find(params[:id])
    if @resident.user_id == @authorized_user.id
      render json: @resident, Resident::JSON_OPTION_USER_ID => @authorized_user.id
      return true
    else
      render json: ['Cannot show other residents.'], :status => :forbidden
    end

  end

=begin

  before_filter(:only => :me) { |controller| controller.send(:confirm_authorization) }
  def me
    if params[:city_id].nil?
      render json: ['Parameter city_id is required.'], status: :unprocessable_entity
      return false
    end

    resident_me = Resident.where(:city_id => params[:city_id], :user_id => @authorized_user.id).first
    if resident_me.nil?
      render json: "City (id = #{params[:city_id]}) does not exist or you are not a resident of that city.", status: :unprocessable_entity
      return false
    else
      if resident_me.city.started_at.nil?
        render json: resident_me
        return true
      else
        if resident_me.role_seen
          render json: resident_me, Resident::JSON_OPTION_USER_ID => @authorized_user.id
          return true
        else
          resident_me.role_seen = true
          resident_me.saved_role_id = resident_me.role_id
          resident_me.save()

          render json: resident_me, Resident::JSON_OPTION_USER_ID => @authorized_user.id
          return true
        end
      end
    end

  end

=end


  before_filter(:only => :save_role) { |controller| controller.send(:confirm_authorization) }
  api :POST, '/residents/save_role', "Save a role."
  description "Save a role. User specifies which role will appear the next time they log into the game. To be more precise, they specify which role will be inside their 'saved_role' property of their #{RESOURCE} object the next time they access it."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :required => true, :desc => "A city id."
  param :saved_role_id, Integer, :required => true, :desc => "A role id to be saved."
  def save_role
    if params[:city_id].nil?
      render json: ["Parameter city_id is required."], status: :unprocessable_entity
      return false
    end

    if params[:saved_role_id].nil?
      render json: ["Parameter saved_role_id is required."], status: :unprocessable_entity
      return false
    end

    @resident = Resident.where(:city_id => params[:city_id], :user_id => @authorized_user.id).first
    if @resident.nil?
      render json: ["Cannot save role. You are not a part of city ID:#{params[:city_id]}."], status: :unprocessable_entity
      return false
    end

    saved_role_id = params[:saved_role_id].to_i
    if saved_role_id
      city_has_role = @resident.city.city_has_roles.where(:role_id => saved_role_id).first
      if city_has_role.nil?
        render json: ["This role is not supported for selected city."], status: :unprocessable_entity
        return false
      else
        @resident.saved_role_id = saved_role_id
        @resident.save
        render json: @resident, Resident::JSON_OPTION_USER_ID => @authorized_user.id
        return true
      end

    else
      render json: ["Parameter saved_role_id must be numeric."], status: :unprocessable_entity
      return false
    end


  end

  # GET /residents/new
  # GET /residents/new.json
  api :GET, '/residents/new', "A new #{RESOURCE}."
  description "A new #{RESOURCE}."
  def new
    @resident = Resident.new
    render json: @resident
  end

  # GET /residents/1/edit
  # def edit
  #   @resident = Resident.find(params[:id])
  # end

  # POST /residents
  # POST /residents.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization) }
  def create
    @resident = Resident.new(params[:resident])

    @resident.user = @authorized_user
    if @resident.city.started_at == nil
      if @resident.save
        render json: @resident, status: :created, location: @resident
      else
        render json: @resident.errors, status: :unprocessable_entity
      end
    else
      head :forbidden
      return false
    end
  end

  # PUT /residents/1
  # PUT /residents/1.json
  def update
    head :forbidden
    return false

    #@resident = Resident.find(params[:id])
    #
    #
    #   if @resident.update_attributes(params[:resident])
    #    head :no_content
    # else
    #   render json: @resident.errors, status: :unprocessable_entity
    # end

  end

  # DELETE /residents/1
  # DELETE /residents/1.json
  def destroy
    head :forbidden
    return false

    # @resident = Resident.find(params[:id])
    # @resident.destroy
    # head :no_content
  end


end
