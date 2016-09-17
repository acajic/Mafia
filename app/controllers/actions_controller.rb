require "rubygems"
require "json"

class ActionsController < ApplicationController
  include ApipieParams::Action

  RESOURCE = 'Action'


  resource_description do
    short "A user interacts with a game via #{RESOURCE.pluralize()}."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "A user interacts with a game via #{RESOURCE.pluralize()}. To vote someone out, user casts a vote. That is an #{RESOURCE}.
For a detective to investigate or a doctor to protect someone, these are also #{RESOURCE.pluralize()}.

There are four types of #{RESOURCE.pluralize()} in regard to their trigger time:
1. DAY_START - #{RESOURCE} gets processed in the 'morning' (moment when a night phase ends and a day phase begins).
2. NIGHT_START - #{RESOURCE} gets processed in the 'evening' (moment when a day phase ends and a night phase begins).
3. BOTH - #{RESOURCE} gets processed both in the morning and in the evening.
4. ASYNC - #{RESOURCE} gets processed immediately or within specified delay after the submission.

When an #{RESOURCE} gets processed, it produces an Action Result.
"
  end

  # GET /actions
  # GET /actions.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  api :GET, '/actions', "[ADMIN] Query #{RESOURCE.pluralize()}."
  description "[ADMIN] Query #{RESOURCE.pluralize()}."
  param_group :auth_required, ApipieParams::Auth
  param :username, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose users' usernames contain this string"
  param :city_name, String, :required => false, :desc => "#{RESOURCE.pluralize()} commited within a city whose name contains this string."
  param :input_json, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose input_json contains this string."
  param :role_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} that were commited by one of these roles. Example:
  exposemafia.com:3000/actions?role_ids[]=6&role_ids[]=5"
  param :role_authentic, ['true', 'false'], :required => false, :desc => "#{RESOURCE.pluralize()} that are commited by authentic (non-fake) role."
  param :action_type_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} whose type is one of the specified types. Example:
  exposemafia.com:3000/actions?action_type_ids[]=4&action_type_ids[]=3"
  param :day_min, Integer, :required => false, :desc => "#{RESOURCE.pluralize()} that are commited on or after the specified game day."
  param :day_max, Integer, :required => false, :desc => "#{RESOURCE.pluralize()} that are commited on or before the specified game day."
  param :resident_alive, ['true', 'false'], :required => false, :desc => "Was the resident alive when they submitted the #{RESOURCE}?"
  param :is_processed, ['true', 'false'], :required => false, :desc => "Is the #{RESOURCE} processed?"
  param :created_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created after this timestamp will be returned."
  param :created_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created before this timestamp will be returned."
  param :page_index, Integer, :required => false, :desc => "Page index."
  param :page_size, Integer, :required => false, :desc => "Page size."
  show false
  def index
    @actions = Action.joins(:role, :action_type, :resident => [:user, :city]).joins('LEFT JOIN days ON actions.day_id = days.id').all

    unless params[:username].nil? || params[:username].empty?
      @actions = @actions.where("users.username LIKE '%#{params[:username]}%'")
    end

    unless params[:city_name].nil? || params[:city_name].empty?
      @actions = @actions.where("cities.name LIKE '%#{params[:city_name]}%'")
    end

    unless params[:input_json].nil? || params[:input_json].empty?
      @actions = @actions.where("input_json LIKE '%#{params[:input_json]}%'")
    end

    unless params[:role_ids].nil?
      @actions = @actions.where(:role_id => params[:role_ids])
    end

    unless params[:role_authentic].nil? || params[:role_authentic].empty?
      role_authentic = params[:role_authentic].downcase == 'true'
      if role_authentic
        @actions = @actions.where('actions.role_id = residents.role_id')
      else
        @actions = @actions.where('actions.role_id != residents.role_id')
      end

    end

    unless params[:action_type_ids].nil?
      @actions = @actions.where(:action_type_id => params[:action_type_ids])
    end

    unless params[:day_min].nil? || params[:day_min].empty?
      @actions = @actions.where('days.number >= ?', params[:day_min].to_i())
    end

    unless params[:day_max].nil? || params[:day_max].empty?
      @actions = @actions.where('days.number <= ?', params[:day_max].to_i())
    end

    unless params[:resident_alive].nil? || params[:resident_alive].empty?
      @actions = @actions.where(:resident_alive => params[:resident_alive].downcase == 'true')
    end

    unless params[:is_processed].nil? || params[:is_processed].empty?
      @actions = @actions.where(:is_processed => params[:is_processed].downcase == 'true')
    end

    unless params[:created_at_min].nil? || params[:created_at_min].empty?
      @actions = @actions.where('actions.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].nil? || params[:created_at_max].empty?
      @actions = @actions.where('actions.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      @actions = @actions.limit(page_size).offset(page_size*page_index)
    end

    @actions.order!('actions.id DESC')

    render json: @actions
  end

  # GET /actions/1
  # GET /actions/1.json
  def show
    head :forbidden

    # @action = Action.find(params[:id])

    # render json: @action
  end

  # GET /actions/new
  # GET /actions/new.json
  api :GET, '/actions/new', "Get a template for creating a new #{RESOURCE}."
  description  "Get a template for creating a new #{RESOURCE}."
  def new
    @action = Action.new

    render json: @action
  end

  # GET /actions/1/edit
  def edit
    head :forbidden
    # @action = Action.find(params[:id])
  end

  # POST /actions
  # POST /actions.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization) }
  api :POST, '/actions', "Create a new #{RESOURCE}."
  description "Create a new  #{RESOURCE}. Example:
  #{CREATE_ACTION_DESC}
"
  param_group :auth_required, ApipieParams::Auth
  param_group :create_action, ApipieParams::Action
  def create
    errors = []
    resident = nil
    day = nil


    unless params.has_key?(:action_instance)
      errors << 'Parameter action is required'
      render json: errors, status: :unprocessable_entity
      return false
    end


    if params[:action_instance].has_key?(:city_id)
      action_type_id = params[:action_instance][:action_type_id]
      action_type = ActionType.find(action_type_id)
      unless action_type.can_submit_manually
        errors << 'Cannot create this type of action manually'
        render json: errors, status: :unprocessable_entity
        return false
      end

      resident = Resident.includes(:city).where(:city_id => params[:action_instance][:city_id], :user_id => @authorized_user.id).first()

      if resident.nil?
        errors << 'Cannot post an action to this city'
        render json: errors, status: :unprocessable_entity
        return false
      end

      unless resident.city.started_at
        errors << 'Cannot post an action to a city that is not yet active'
      end

      if params[:action_instance].has_key?(:day_id)
        day = Day.find(params[:action_instance][:day_id])
        if day.nil? || resident.city_id != day.city_id
          errors << 'Invalid parameter action.day_id'
        end
      elsif params[:action_instance].has_key?(:day_number)
        day = Day.where(:city_id => resident.city_id, :number => params[:action_instance][:day_number]).first()
        if day.nil?
          errors << 'Invalid parameter action.day_number'
        end
      else
        errors << 'One of the parameters action.day_id or action.day_number is required'
      end
    else
      errors << 'Parameter action.city_id is required'
    end


    if errors.length > 0
      render json: errors, status: :unprocessable_entity
      return false
    end


    action_hash = Action.init_hash(params[:action_instance])
    action_hash[:resident_id] = resident.id
    action_hash[:resident_alive] = nil # will be assigned in Action's before_create handler
    action_hash[:day_id] = day.id

    @action = Action.new(action_hash)

    if @action.save
      render json: @action, status: :created, location: @action
    else
      render json: @action.errors, status: :unprocessable_entity
    end

  end

  # PUT /actions/1
  # PUT /actions/1.json
  def update
    head :forbidden

    #@action = Action.find(params[:id])

    #if @action.update_attributes(params[:action])
    #   head :no_content
    # else
    #  render json: @action.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /actions/1
  # DELETE /actions/1.json
  def destroy
    head :forbidden
    # @action = Action.find(params[:id])
    # @action.destroy

    # head :no_content
  end

  # DELETE /actions/cancel_unprocessed_actions
  api :DELETE, '/actions/cancel_unprocessed_actions', "Cancel all #{RESOURCE.pluralize()} that haven't yet been processed."
  description "Cancel all #{RESOURCE.pluralize()} that haven't yet been processed. Example:
  #{DELETE_ACTION_DESC}
"
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :desc => "City id.", :required => true
  param :role_id, Integer, :desc => "Role id.", :required => false
  param :action_type_id, Integer, :desc => "Action type id.", :required => false
  before_filter(:only => :cancel_unprocessed_actions) { |controller| controller.send(:confirm_authorization) }
  def cancel_unprocessed_actions
    unless params.has_key?(:city_id)
      render json: ['Parameters [city_id] are required.'], :status => :unprocessable_entity
      return
    end

    resident = Resident.where(:city_id => params[:city_id], :user_id => @authorized_user.id).first
    if resident.nil?
      render json: ["You are not a resident of city id=#{params[:city_id]}."]
      return
    end

    Action.cancel_unprocessed_actions(params[:city_id], @authorized_user.id, params[:role_id], params[:action_type_id], params[:day])

    head :no_content
  end

end
