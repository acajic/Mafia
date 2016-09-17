class ActionResultsController < ApplicationController
  include ApipieParams::ActionResult

  RESOURCE = 'Action Result'


  resource_description do
    short "#{RESOURCE.pluralize()} provide insight into the state of the game."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "#{RESOURCE.pluralize()} are a way of insight into the state of the game. Players' actions produce results.
Who got killed by Mafia this morning? Who got voted out yesterday? Who is currently alive and who isn't?
All of these are #{RESOURCE.pluralize()}.
"
  end

  # GET /action_results
  # GET /action_results.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  api :GET, '/action_results', "[ADMIN] Query #{RESOURCE.pluralize()}."
  description "[ADMIN] Query #{RESOURCE.pluralize()}."
  param_group :auth_required, ApipieParams::Auth
  param :result_json, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose result_json contains this string."
  param :action_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} that were produces by one of these actions. Example:
  exposemafia.com:3000/action_results?action_ids[]=62&action_ids[]=63"
  param :action_result_type_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} that are of these types. Example:
  exposemafia.com:3000/action_results?action_result_type_ids[]=4&action_result_type_ids[]=5"
  param :is_automatically_generated, ['true', 'false'], :required => false, :desc => "Is the #{RESOURCE} automatically generated? If 'true', the #{RESOURCE} is authentic. If 'false', the #{RESOURCE} is faked by the user."
  param :city_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} from the specified cities. Example:
  exposemafia.com:3000/action_results?city_ids[]=6&city_ids[]=5"
  param :city_name, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose name contains this string."
  param :day_number_min, Integer, :required => false, :desc => "#{RESOURCE.pluralize()} that are produced on or after the specified game day."
  param :day_number_max, Integer, :required => false, :desc => "#{RESOURCE.pluralize()} that are produced on or before the specified game day."
  param :resident_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} produces specifically for specified residents. Example:
  exposemafia.com:3000/action_results?resident_ids[]=16&resident_ids[]=17&resident_ids[]=21"
  param :for_all_residents, ['true', 'false'], :required => false, :desc => "Return only the #{RESOURCE.pluralize()} that are intended for all the residents in the city ('true'), or the ones that are intended only for specific residents ('false')."
  param :resident_username, String, :required => false, :desc => "#{RESOURCE.pluralize()} that are intended for a resident whose name contains this string."
  param :role_ids, Array, of: Integer, :required=> false, :desc => "#{RESOURCE.pluralize()} for the specific roles. Example:
  exposemafia.com:3000/action_results?role_ids[]=3&role_ids[]=2"
  param :deleted, ['true', 'false'], :required => false, :desc => "Return only the #{RESOURCE.pluralize()} were deleted by the user ('true'), or the ones that weren't deleted by the user ('false')."
  param :created_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created after this timestamp will be returned."
  param :created_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created before this timestamp will be returned."
  param :updated_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were updated after this timestamp will be returned."
  param :updated_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were updated before this timestamp will be returned."
  param :page_index, Integer, :required => false, :desc => "Page index."
  param :page_size, Integer, :required => false, :desc => "Page size."
  show false
  def index

    result = ActionResult.joins('LEFT JOIN actions ON action_results.action_id = actions.id')
    .joins('LEFT JOIN cities ON action_results.city_id = cities.id')
    .joins('LEFT JOIN days ON action_results.day_id = days.id')
    .joins('LEFT JOIN residents ON action_results.resident_id = residents.id')
    .joins('LEFT JOIN users ON residents.user_id = users.id')
    .all

    unless params[:action_ids].nil?
      result = result.where('actions.id' => params[:action_ids])
    end

    unless params[:action_result_type_ids].nil?
      result = result.where(:action_result_type_id => params[:action_result_type_ids])
    end

    unless params[:result_json].nil? || params[:result_json].empty?
      result = result.where("action_results.result_json LIKE '%#{params[:result_json]}%'")
    end

    unless params[:is_automatically_generated].nil? || params[:is_automatically_generated].empty?
      result = result.where(:is_automatically_generated => params[:is_automatically_generated].downcase == 'true')
    end

    unless params[:city_ids].nil?
      result = result.where(:city_id => params[:city_ids])
    end

    unless params[:city_name].nil? || params[:city_name].empty?
      result = result.where("cities.name LIKE '%#{params[:city_name]}%'")
    end

    unless params[:day_number_min].nil? || params[:day_number_min].empty?
      result = result.where('days.number >= ?', params[:day_number_min].to_i())
    end

    unless params[:day_number_max].nil? || params[:day_number_max].empty?
      result = result.where('days.number <= ?', params[:day_number_max].to_i())
    end

    unless params[:resident_ids].nil?
      result = result.where(:resident_id => params[:resident_ids])
    end

    unless params[:resident_username].nil? || params[:resident_username].empty?
      result = result.where("users.username LIKE '%#{params[:resident_username]}%'")
    end

    unless params[:for_all_residents].nil? || params[:for_all_residents].empty?
      if params[:for_all_residents].downcase == 'true'
        result = result.where('action_results.resident_id IS NULL')
      end
    end

    unless params[:role_ids].nil?
      result = result.where('action_results.role_id IN (?) OR action_results.role_id IS NULL', params[:role_ids])
    end

    unless params[:deleted].nil? || params[:deleted].empty?
      result = result.where(:deleted => params[:deleted].downcase == 'true')
    end

    unless params[:created_at_min].nil? || params[:created_at_min].empty?
      result = result.where('action_results.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].nil? || params[:created_at_max].empty?
      result = result.where('action_results.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    unless params[:updated_at_min].nil? || params[:updated_at_min].empty?
      result = result.where('action_results.updated_at >= ?', Time.at(params[:updated_at_min].to_i()).to_datetime())
    end

    unless params[:updated_at_max].nil? || params[:updated_at_max].empty?
      result = result.where('action_results.updated_at <= ?', Time.at(params[:updated_at_max].to_i()).to_datetime())
    end

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      result = result.limit(page_size).offset(page_size*page_index)
    end

    result.order!('action_results.id DESC')

    render(:json => result, ActionResult::JSON_OPTION_SHOW_ALL => true)
  end


  # GET /action_results/city/1/role/4
  # GET /action_results/city/1/role/4.json
  before_filter(:only => :action_results_for_city_and_role) { |controller| controller.send(:confirm_authorization) }
  api :GET, '/action_results/city/:city_id/role/:role_id', "Get #{RESOURCE.pluralize()} for a specific city and role."
  description "Get #{RESOURCE.pluralize()} for a specific city and role. This data is normally accessed when user enters a game in order to receive most up-to-date information about the state of the game."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :required => true, :desc => "City id."
  param :role_id, Integer, :required => true, :desc => "Role id."
  param :day_number_min, Integer, :required => false, :desc => "#{RESOURCE.pluralize()} that are produced on or after the specified game day."
  param :day_number_max, Integer, :required => false, :desc => "#{RESOURCE.pluralize()} that are produced on or before the specified game day."
  param :action_type_id, Integer, :required => false, :desc => "Action type id."
  def action_results_for_city_and_role
    if params[:city_id].nil?
      render json: 'Parameter city_id is required.', status: :unprocessable_entity
      return false
    end

    day_number_min = nil
    unless params[:day_number_min].nil? || params[:day_number_min].empty?
      day_number_min = params[:day_number_min].to_i()
    end

    day_number_max = nil
    unless params[:day_number_max].nil? || params[:day_number_max].empty?
      day_number_max = params[:day_number_max].to_i()
    end


    role_id = params[:role_id]
    if role_id.nil? || role_id == 'null'
      city = City.find(params[:city_id])
      is_owner = @authorized_user.id == city.user_creator_id
      if is_owner
        observer_action_results = ActionResult.observer_action_results(city.id, day_number_min, day_number_max)
        render json: observer_action_results
        return true
      else
        render json: 'Parameter role_id is required.', status: :unprocessable_entity
        return false
      end

    end







    filtered_action_results = ActionResult.query_action_results(params[:city_id], @authorized_user.id, params[:role_id], params[:action_type_id], day_number_min, day_number_max)

    render json: filtered_action_results
  end

  # GET /action_results/1
  # GET /action_results/1.json
  def show
    head :forbidden

    # @action_result = ActionResult.find(params[:id])

    # render json: @action_result
  end

  # GET /action_results/new
  # GET /action_results/new.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization) }
  api :GET, '/action_results/new', "A new #{RESOURCE}."
  description "A new #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :required => true, :desc => "City id."
  param :role_id, Integer, :required => true, :desc => "Role id."
  def new
    unless params.has_key?(:city_id) && params.has_key?(:role_id)
      render json: ["Parameter city_id is required.", "Parameter role_id is required."], status: :unprocessable_entity
      return false
    end

    @action_result = ActionResult.new(:city_id => params[:city_id], :role_id => params[:role_id])

    resident = City.find(params[:city_id]).get_resident_by_user_id(@authorized_user.id)
    if resident.nil?
      render json: ["Cannot create action result for city you are not a resident of."], status: :unprocessable_entity
      return false
    else
      @action_result.resident_id = resident.id
    end

    render json: @action_result
  end

  # GET /action_results/1/edit
  def edit
    head :forbidden
    #@action_result = ActionResult.find(params[:id])

    #render json: @action_result
  end

  # POST /action_results
  # POST /action_results.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization) }
  api :POST, '/action_results', "Create a new #{RESOURCE}."
  description "Create a new #{RESOURCE}. Normally, action results are created automatically when actions get processed. Users can always submit fake action results which will later be undistinguishable from the genuine ones. Example parameters:
#{ACTION_RESULT_DESC}
"
  param_group :auth_required, ApipieParams::Auth
  param_group :create_action_result, ApipieParams::ActionResult
  def create
    if params[:action_result].nil?
      render json: ['Parameter action_result is required.'], status: :unprocessable_entity
      return false
    end

    if params[:action_result][:city_id].nil?
      render json: ['Parameter action_result.city_id is required.'], status: :unprocessable_entity
      return false
    end

    city_id = params[:action_result][:city_id].to_i

    unless params[:action_result][:day_id].nil?
      day_id = params[:action_result][:day_id]
      day = Day.find(day_id)
      if day.nil? || day.city_id != city_id
        render json: ['Cannot create action result for specified day.'], status: :unprocessable_entity
        return false
      end
    end


    resident = Resident.where(:city_id => city_id, :user_id => @authorized_user.id).first()
    if resident.nil?
      render json: ['Cannot create action result for city you are not a resident of.'], status: :unprocessable_entity
      return false
    end

    params[:action_result][:resident_id] = resident.id


    if params[:action_result][:action_result_type].nil? || params[:action_result][:action_result_type][:id].nil?
      render json: ['Cannot create action result of unspecified type.'], status: :unprocessable_entity
      return false
    else
      action_result_type_id = params[:action_result][:action_result_type][:id]
      action_result_type = ActionResultType.find(action_result_type_id)
      if action_result_type.nil?
        render json: ['Specified action result type does not exist.'], status: :unprocessable_entity
        return false
      end
    end


    action_result_hash = ActionResult.init_hash(params.require(:action_result))

    @action_result = ActionResult.new(action_result_hash)

    @action_result.resident_id = resident.id
    @action_result.is_automatically_generated = false

    #delete_matching_action_results(@action_result)
    if @action_result.save
      render json: @action_result, status: :created
    else
      render json: @action_result.errors, status: :unprocessable_entity
    end

  end


  # PUT /action_results/1
  # PUT /action_results/1.json
  before_filter(:only => :update) { |controller| controller.send(:check_is_auto_generated) }
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization) }

  def update
    head :forbidden

    #@action_result = ActionResult.find(params[:id])
    #
    #   if @action_result.update_attributes(params[:action_result])
    #    head :no_content
    # else
    #  render json: @action_result.errors, status: :unprocessable_entity
    #end

  end


  # DELETE /action_results/1
  # DELETE /action_results/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization) }
  api :DELETE, '/action_results/:action_result_id', "Delete an #{RESOURCE}."
  description "Delete an #{RESOURCE}. On the user for whom the action result is intended can delete it."
  param_group :auth_required, ApipieParams::Auth
  param :action_result_id, Integer, :desc => "An #{RESOURCE} id.", :required => true
  def destroy
    @action_result = ActionResult.find(params[:id])

    if @action_result.resident_id.nil?
      cloned_action_result = @action_result.dup()
      resident = Resident.where(:city_id => @action_result.city_id, :user_id => @authorized_user.id).first()
      if resident.nil?
        head :forbidden
        return false
      end
      cloned_action_result.resident_id = resident.id
      cloned_action_result.deleted = true
      cloned_action_result.save()
      head :no_content
      return true
    end

    if @action_result.resident.user_id != @authorized_user.id
      head :forbidden
      return false
    end

    @action_result.deleted = true
    @action_result.save()
    head :no_content
  end


=begin
  def names_for_action_result_types
    action_result_classes = ActionResultType.all_action_result_classes
    action_result_names_per_class_names = {}
    action_result_classes.each { |action_result_class|
      action_result_names_per_class_names[action_result_class.name] = action_result_class.action_result_name
    }

    render json: action_result_names_per_class_names
  end
=end

  private

  def check_is_auto_generated
    action_result_hash = params[:action_result]
    if action_result_hash.has_key?(:is_automatically_generated)
      if action_result_hash[:is_automatically_generated]
        head :forbidden
        return false
      end
    end
  end


end
