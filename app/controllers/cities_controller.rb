class CitiesController < ApplicationController
  include ApipieParams::City


  RESOURCE = 'City'


  resource_description do
    short 'Cities or Towns are basically games.'
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description 'Cities (or Towns, or Games). Each City is a single Mafia game.'
  end





# GET /cities
# GET /cities.json
  before_filter(:only => :index) { |controller| controller.send(:optional_authorization) }

  api :GET, '/cities', 'Query cities/towns/games'
  description 'Query cities/towns/games'
  param :name, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose names contain this string will be returned."
  param :description, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose descriptions contain this string will be returned."
  param :resident_user_ids, Array, of: Integer, :required=> false, :desc => "If one of the specified users are a part of a #{RESOURCE}, that city will be returned. Example:
  exposemafia.com:3000/cities?resident_user_ids[]=6&resident_user_ids[]=5"
  param :public, ['true', 'false'], :required => false, :desc => "#{RESOURCE.pluralize()} that are public or the ones that are private will be returned."
  param :active, ['true', 'false'], :required => false, :desc => "#{RESOURCE.pluralize()} that are active (started and ongoing) or the ones that are inactive (not started or finished) will be returned."
  param :paused, ['true', 'false'], :required => false, :desc => "#{RESOURCE.pluralize()} that are paused or the ones that are not paused will be returned."
  param :paused_during_day, ['true', 'false'], :required => false, :desc => "#{RESOURCE.pluralize()} that are paused during day phase of the game or the ones that are paused during night phase of the game will be returned."
  param :started_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that started after this timestamp will be returned."
  param :started_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that started before this timestamp will be returned."
  param :paused_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were paused after this timestamp will be returned."
  param :paused_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were paused before this timestamp will be returned."
  param :finished_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were finished after this timestamp will be returned."
  param :finished_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were finished before this timestamp will be returned."
  param :created_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created after this timestamp will be returned."
  param :created_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created before this timestamp will be returned."
  param :updated_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were updated after this timestamp will be returned."
  param :updated_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were updated before this timestamp will be returned."
  param :page_index, Integer, :required => false, :desc => "Page index."
  param :page_size, Integer, :required => false, :desc => "Page size."
  def index
    @cities = City
      .includes(:self_generated_result_types, :user_creator, :day_cycles, :roles, :game_end_conditions, :residents => :user).all

    unless params[:name].nil? || params[:name].empty?
      @cities = @cities.where("cities.name LIKE '%#{params[:name]}%'")
    end

    unless params[:description].nil? || params[:description].empty?
      @cities = @cities.where("cities.description LIKE '%#{params[:description]}%'")
    end

    unless params[:resident_user_ids].nil?
      @cities = @cities.where('residents.user_id' => params[:resident_user_ids])
    end


    unless params[:public].nil? || params[:public].empty?
      @cities = @cities.where(:public => params[:public].downcase == 'true')
    end

    unless params[:active].nil? || params[:active].empty?
      @cities = @cities.where(:active => params[:active].downcase == 'true')
    end

    unless params[:paused].nil? || params[:paused].empty?
      @cities = @cities.where(:paused => params[:paused].downcase == 'true')
    end

    unless params[:paused_during_day].nil? || params[:paused_during_day].empty?
      @cities = @cities.where(:paused_during_day => params[:paused_during_day].downcase == 'true')
    end

    unless params[:started_at_min].nil? || params[:started_at_min].empty?
      @cities = @cities.where('started_at >= ?', Time.at(params[:started_at_min].to_i()).to_datetime())
    end

    unless params[:started_at_max].nil? || params[:started_at_max].empty?
      @cities = @cities.where('started_at <= ?', Time.at(params[:started_at_max].to_i()).to_datetime())
    end

    unless params[:paused_at_min].nil? || params[:paused_at_min].empty?
      @cities = @cities.where('paused_at >= ?', Time.at(params[:paused_at_min].to_i()).to_datetime())
    end

    unless params[:paused_at_max].nil? || params[:paused_at_max].empty?
      @cities = @cities.where('paused_at <= ?', Time.at(params[:paused_at_max].to_i()).to_datetime())
    end

    unless params[:finished_at_min].nil? || params[:finished_at_min].empty?
      @cities = @cities.where('finished_at >= ?', Time.at(params[:finished_at_min].to_i()).to_datetime())
    end

    unless params[:finished_at_max].nil? || params[:finished_at_max].empty?
      @cities = @cities.where('finished_at <= ?', Time.at(params[:finished_at_max].to_i()).to_datetime())
    end

    unless params[:created_at_min].nil? || params[:created_at_min].empty?
      @cities = @cities.where('created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].nil? || params[:created_at_max].empty?
      @cities = @cities.where('created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    unless params[:updated_at_min].nil? || params[:updated_at_min].empty?
      @cities = @cities.where('updated_at >= ?', Time.at(params[:updated_at_min].to_i()).to_datetime())
    end

    unless params[:updated_at_max].nil? || params[:updated_at_max].empty?
      @cities = @cities.where('updated_at <= ?', Time.at(params[:updated_at_max].to_i()).to_datetime())
    end


    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      @cities = @cities.order('cities.id DESC').limit(page_size).offset(page_size*page_index)
    end

    render json: @cities, City::JSON_OPTION_USER_ID => (@authorized_user ? @authorized_user.id : nil)
  end

  # GET /cities/me
  # GET /cities/me.json
  before_filter(:only => :me) { |controller| controller.send(:confirm_authorization) }
  api :GET, '/cities/me', "Get my #{RESOURCE.pluralize()}"
  description "Get a list of #{RESOURCE.pluralize()} that I either created, am a participant of, am invited to or have requested to join them."
  param_group :auth_required, ApipieParams::Auth
  def me
    owned_cities = City.where(:user_creator_id => @authorized_user.id)
    joined_to_cities = City.includes(:residents => :user).where('users.id' => @authorized_user.id)
    invited_to_cities = City.includes(:invitations => :user).where('users.id' => @authorized_user.id)
    requested_to_join_cities = City.includes(:join_requests => :user).where('users.id' => @authorized_user.id)

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()

      owned_cities_result = owned_cities.order('cities.id DESC').limit(page_size).offset(page_size*page_index).to_a()
      joined_to_cities_result = joined_to_cities.order('cities.id DESC').limit(page_size).offset(page_size*page_index).to_a()
      invited_to_cities_result = invited_to_cities.order('cities.id DESC').limit(page_size).offset(page_size*page_index).to_a()
      requested_to_join_cities_result = requested_to_join_cities.order('cities.id DESC').limit(page_size).offset(page_size*page_index).to_a()
    end

    render json: (owned_cities_result | joined_to_cities_result | invited_to_cities_result | requested_to_join_cities_result), City::JSON_OPTION_USER_ID => @authorized_user.id
  end

  # GET /cities/search/all_cities_for_search_text
  # GET /cities/search/all_cities_for_search_text.json
  before_filter(:only => :all_cities_for_search_text) { |controller| controller.send(:optional_authorization) }
  api :GET, '/cities/search/all_cities_for_search_text', "Get #{RESOURCE.pluralize()} by name."
  description "Get all #{RESOURCE.pluralize()} whose name contains a specified query string."
  param_group :auth_optional, ApipieParams::Auth
  param :search, String, :required => true, :desc => 'A query string.'
  def all_cities_for_search_text
    searchText = params.require(:search)

    all_cities_matching_search = City.where("cities.name like ?", "%#{searchText}%").order('cities.id DESC').limit(50)

    render json: all_cities_matching_search, City::JSON_OPTION_USER_ID => (@authorized_user ? @authorized_user.id : nil)
  end

  # GET /cities/me/search/my_cities_for_search_text
  # GET /cities/me/search/my_cities_for_search_text.json
  before_filter(:only => :my_cities_for_search_text) { |controller| controller.send(:confirm_authorization) }
  api :GET, '/cities/search/my_cities_for_search_text', "Get my #{RESOURCE.pluralize()} by name."
  description "Get my #{RESOURCE.pluralize()} whose name contains a specified query string."
  param_group :auth_required, ApipieParams::Auth
  param :search, String, :required => true, :desc => 'A query string.'
  def my_cities_for_search_text
    searchText = params.require(:search)

    joined_to_cities = City.includes(:residents => :user).where("cities.name like ?", "%#{searchText}%").where('users.id' => @authorized_user.id).order('cities.id DESC').limit(50).to_a()
    invited_to_cities = City.includes(:invitations => :user).where("cities.name like ?", "%#{searchText}%").where('users.id' => @authorized_user.id).order('cities.id DESC').limit(50).to_a()
    requested_to_join_cities = City.includes(:join_requests => :user).where("cities.name like ?", "%#{searchText}%").where('users.id' => @authorized_user.id).order('cities.id DESC').limit(50).to_a()

    render json: (joined_to_cities | invited_to_cities | requested_to_join_cities), City::JSON_OPTION_USER_ID => @authorized_user.id
  end


  # GET /cities/1
  # GET /cities/1.json
  before_filter(:only => :show) { |controller| controller.send(:optional_authorization) }
  api :GET, '/cities/:city_id', "Get a #{RESOURCE} by id."
  description "Get a #{RESOURCE} by id."
  param_group :auth_optional, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  def show
    @city = City.includes(:days, :invitations, :join_requests, :role_picks, :residents).find(params[:id])
    if @city.last_accessed_at.nil? || @city.last_accessed_at < 5.minutes.ago
      @city.last_accessed_at = Time.now()
      @city.save()
    end
    render json: @city, City::JSON_OPTION_USER_ID => (@authorized_user ? @authorized_user.id : nil)
  end


  # GET /cities/new
  # GET /cities/new.json
  before_filter(:only => :new) { |controller| controller.send(:confirm_authorization) }
  api :GET, '/cities/new', "Get a template for creating a new #{RESOURCE}."
  description  "Get a template for creating a new #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  def new
    @city = City.new

    @city.user_creator_id = @authorized_user.id
    creator_resident = Resident.new(:user_id => @authorized_user.id, :city => @city)
    @city.residents << creator_resident
    @city.day_cycles << DayCycle.new(:day_start => 9*60, :night_start => 20*60)
    @city.game_end_conditions << GameEndCondition.first

    #@city.city_has_self_generated_result_types = [
    #    CityHasSelfGeneratedResultType.new(:action_result_type => ActionResultType.find(ActionResultType::RESIDENTS)),
    #    CityHasSelfGeneratedResultType.new(:action_result_type => ActionResultType.find(ActionResultType::ACTION_TYPE_PARAMS))
    #]

    @city.self_generated_result_types = [
        ActionResultType.find(ActionResultType::RESIDENTS),
        ActionResultType.find(ActionResultType::ACTION_TYPE_PARAMS)
    ]

    render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id, City::JSON_OPTION_TEMP_RESIDENTS => true
  end

  #before_filter(:only => :edit) { |controller| controller.send(:confirm_authorization, {:id => params[:id]}) }
  # GET /cities/1/edit
  #def edit
  #  @city = City.find(params[:id])
  #end

  # POST /cities
  # POST /cities.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities', "Create a new #{RESOURCE}."
  description "Create a new  #{RESOURCE}. Example:
  #{CREATE_CITY_DESC}
  "
  param_group :auth_required, ApipieParams::Auth
  param_group :new_city, ApipieParams::City
  def create
    user_can_create_games = @authorized_user.app_permissions.map { |app_permission| app_permission.id}.include?(AppPermission::CREATE_GAMES)
    game_purchase_to_spend = @authorized_user.game_purchases.first()

    if user_can_create_games || game_purchase_to_spend
      city_hash = City.init_hash(params[:city])

      @city = City.new(city_hash)

      @city.user_creator = @authorized_user

      if @city.save()
        render json: @city, status: :created, location: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
        return true
      else
        render json: @city.errors, status: :unprocessable_entity
        return false
      end
    else
      head :unauthorized
      return false
    end


  end


  # POST /cities/1/join
  before_filter(:only => :join) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id/join', "Join a #{RESOURCE}."
  description "Join a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  def join
    @city = City.find(params.require(:id))

    if @city.started_at
      head :unprocessable_entity
      return
    end

    if @city.residents.any?{|r| r.user_id == @authorized_user.id}
      render json: @city, :status => :ok, City::JSON_OPTION_USER_ID => @authorized_user.id
      return
    end


    if @city.public || @city.user_creator_id == @authorized_user.id
      # everything is ok, no additional checks needed
    elsif @city.hashed_password == nil
      # game is not public, check if user is invited
      invitations_relation = @city.invitations.where(:user_id => @authorized_user.id)
      invitation = invitations_relation.first()
      if invitation
        invitations_relation.destroy_all()
        # user was invited so join is successful
      else
        # user is not invited so JoinRequest should be created

        join_request = @city.join_requests.where(:user_id => @authorized_user.id).first()
        if join_request
          render json: {:city => @city.as_json(City::JSON_OPTION_USER_ID => @authorized_user.id), :message => 'You have already requested to join this game.', :outcome => 3}, :status => :ok, City::JSON_OPTION_USER_ID => @authorized_user.id
        else
          @city.join_requests << JoinRequest.new(:user_id => @authorized_user.id)
          if @city.save()
            render json: {:city => @city.as_json(City::JSON_OPTION_USER_ID => @authorized_user.id), :message => 'You have requested to join the game.', :outcome => 2}, :status => :created, City::JSON_OPTION_USER_ID => @authorized_user.id
          else
            render json: @city.errors, status: :unprocessable_entity
          end
        end

        return

      end

    else

      param_password = params.require(:password)
      password_ok = Static::PasswordUtility.check_password(param_password, @city.password_salt, @city.hashed_password)
      if password_ok
        # everything ok, user is cleared to join the game
      else
        @city.errors.add(:password, 'Password incorrect')
        render json: @city.errors, status: :unprocessable_entity
        return false
      end

    end


    @city.residents << Resident.new(:user_id => @authorized_user.id)

    if @city.save()
      render json: {:city => @city.as_json(City::JSON_OPTION_USER_ID => @authorized_user.id), :message => 'You have successfully joined.', :outcome => 1}, :status => :created
    else
      render json: @city.errors, status: :unprocessable_entity
    end

  end





  # DELETE /cities/1/join_request
  before_filter(:only => :cancel_join_request) { |controller| controller.send(:confirm_authorization) }
  api :DELETE, '/cities/:city_id/join_request', "Cancel a request to join a #{RESOURCE}."
  description "Cancel a request to join a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  def cancel_join_request
    @city = City.find(params.require(:id))

    join_requests = @city.join_requests.where(:user_id => @authorized_user.id)
    join_request = join_requests.first()

    if join_request
      join_requests.destroy_all()
      render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
    else
      render json: 'You have not requested to join to this game.', :status => :no_content
    end

  end




  # POST /cities/1/accept_invitation
  before_filter(:only => :accept_invitation) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id/accept_invitation', "Accept an invitation to join a #{RESOURCE}."
  description "Accept an invitation to join a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  def accept_invitation
    @city = City.find(params[:id])

    if @city.started_at
      head :forbidden
      return
    end

    invitation_records = @authorized_user.invitations.where(:city_id => @city.id)

    invitation = invitation_records.first()
    invitation_records.destroy_all()

    if @city.residents.any?{|r| r.user_id == @authorized_user.id}
      render json: @city, :status => :ok, City::JSON_OPTION_USER_ID => @authorized_user.id
      return
    end

    if invitation
      @city.residents << Resident.new(:user_id => @authorized_user.id)

      if @city.save()
        render json: @city, :status => :created, City::JSON_OPTION_USER_ID => @authorized_user.id
      else
        render json: @city.errors, status: :unprocessable_entity
      end
    else
      render json: 'You are not invited.', status: :unauthorized
    end

  end


  # POST /cities/1/join_request/2
  before_filter(:only => :accept_join_request) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id/accept_join_request', "Accept a User's request to join a #{RESOURCE} you created."
  description "Accept a User's request to join a #{RESOURCE} you created."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  param :user_id, Fixnum, :required => true, :desc => "An id of a User who requested to join."
  def accept_join_request
    @city = City.find(params[:id])

    if @authorized_user.id != @city.user_creator_id
      head :unauthorized
      return
    end

    if @city.started_at
      head :unprocessable_entity
      return
    end

    join_request_records = @city.join_requests.where(:user_id => params.require(:user_id))
    join_request = join_request_records.first()
    join_request_records.destroy_all()

    if @city.residents.any?{|r| r.user_id == params.require(:user_id)}
      render json: @city, :status => :ok, City::JSON_OPTION_USER_ID => @authorized_user.id
      return
    end

    if join_request
      @city.residents << Resident.new(:user_id => params.require(:user_id))

      if @city.save()
        joined_user = User.find(params.require(:user_id))

        if joined_user.user_preference.receive_notifications_when_added_to_game
          InfoMailer.notify_user_join_request_accepted(joined_user, @city, @authorized_user)
        end

        render json: @city, :status => :created, City::JSON_OPTION_USER_ID => @authorized_user.id
      else
        render json: @city.errors, status: :unprocessable_entity
      end

    else
      render json: 'The user has not requested to join.', status: :unprocessable_entity
    end



  end


  # POST /cities/1/leave
  before_filter(:only => :leave) { |controller| controller.send(:confirm_authorization) }
  api :POST, '/cities/:city_id/leave', "Leave a #{RESOURCE}."
  description "Cancel your participation in a #{RESOURCE}. You can only leave before the game started."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  def leave
    @city = City.find(params.require(:id))

    if @city.started_at
      head :forbidden
      return
    end

    unless @city.residents.any?{|r| r.user_id == @authorized_user.id}
      render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
      return
    end

    leaving_resident = Resident.where(:city_id => @city.id, :user_id => @authorized_user.id).first
    if leaving_resident.nil?
      render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
      return
    end


    Resident.destroy(leaving_resident.id)


    @city.reload()
    if @city.save()
      render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
    else
      render json: @city.errors, status: :unprocessable_entity
    end


  end


  # DELETE /cities/1/invitation/2
  before_filter(:only => :cancel_invitation) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :DELETE, '/cities/:city_id/invitation/:user_id', "Cancel an invitation sent to a User to join a #{RESOURCE}."
  description "Cancel an invitation sent to a User to join a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  param :user_id, Fixnum, :required => true, :desc => "A User id."
  def cancel_invitation
    @city = City.find(params.require(:id))
    unless @city.user_creator_id == @authorized_user.id
      head :unauthorized
      return false
    end

    unless params.has_key?(:user_id)
      render json: {:errors => ["Parameter 'user_id' is required."]}, :status => :unprocessable_entity
      return false
    end


    @city.invitations.where(:user_id => params.require(:user_id)).destroy_all()


    render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
  end


  # DELETE /cities/1/join_request/2
  before_filter(:only => :reject_join_request) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :DELETE, '/cities/:city_id/join_request/:user_id', "Reject a join request of a User to join a #{RESOURCE}."
  description "Reject a join request of a User to join a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  param :user_id, Fixnum, :required => true, :desc => "A User id."
  def reject_join_request
    @city = City.find(params.require(:id))
    unless @city.user_creator_id == @authorized_user.id
      head :unauthorized
      return false
    end

    unless params.has_key?(:user_id)
      render json: {:errors => ["Parameter 'user_id' is required."]}, :status => :unprocessable_entity
      return false
    end


    @city.join_requests.where(:user_id => params.require(:user_id)).destroy_all()


    render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id

  end


  # DELETE /cities/1/user/2
  before_filter(:only => :kick_user) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :DELETE, '/cities/:city_id/user/:user_id', "Kick a user out of your #{RESOURCE}."
  description "Kick a user out of your #{RESOURCE}. You can only kick someone out before the game has started."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Fixnum, :required => true, :desc => "A #{RESOURCE} id."
  param :user_id, Fixnum, :required => true, :desc => "A User id."
  def kick_user
    @city = City.find(params.require(:id))
    unless @city.user_creator_id == @authorized_user.id
      head :unauthorized
      return false
    end

    unless params.has_key?(:user_id)
      render json: {:errors => ["Parameter 'user_id' is required."]}, :status => :unprocessable_entity
      return false
    end

    if @city.started_at
      render json: {:errors => ['Cannot kick a user from the game that has already started.']}, :status => :unprocessable_entity
      return false
    end

    @city.residents.where(:user_id => params[:user_id]).destroy_all()

    render json: @city
  end

  # POST /cities/1/invite
  before_filter(:only => :invite) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id/invite', "Invite users to your #{RESOURCE}."
  description "Invite users to your #{RESOURCE}. You can only invite users before the game has started."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  def invite
    @city = City.find(params.require(:id))

    unless @city.user_creator_id == @authorized_user.id
      head :unauthorized
      return false
    end


    if @city.started_at.nil?
      if params[:invited_users].nil? || params[:invited_users].empty?
        head :unprocessable_entity
        return false
      end

      emails = params[:invited_users].map { |param_user| param_user[:email] }
      ids = params[:invited_users].map { |param_user| param_user[:id] }
      already_joined_users = @city.residents.includes(:user).where(:user_id => ids).map { |r| r.user}
      already_invited_users = @city.invitations.includes(:user).where(:user_id => ids).map { |i| i.user }
      existing_users_by_id = User.where(:id => ids).to_a()
      existing_users_by_email = User.where(:email => emails).to_a()
      existing_users = (existing_users_by_id + existing_users_by_email).uniq() - already_joined_users - already_invited_users
      existing_emails = existing_users_by_email.map { |u| u.email }

      new_user_initializers = params[:invited_users].select { |param_user|
        !existing_emails.include?(param_user.require(:email)) # exclude emails that are already in use
      }.map { |param_user|
        password = ('000' + rand(10000).to_s())[-4, 4] # if random number is 93, password will be '0093'
        {
            :username => param_user.require(:username),
            :email => param_user.require(:email),
            :password => password,
            :repeat_password => password,
            :email_confirmed => true
        }
      }

      new_users = User.create(new_user_initializers)
      new_users_valid = []
      new_users_invalid = []
      new_users.each { |new_user|
        if new_user.valid?
          unless new_user.email.nil? || new_user.password.nil? || new_user.password.empty?
            InfoMailer.welcome_user_and_send_password(new_user, new_user.password)
          end
          new_user.password = nil
          new_user.repeat_password = nil
          new_users_valid << new_user
        else
          new_users_invalid << new_user
        end
      }

      added_users = existing_users + new_users_valid
      resident_initializers = []
      invitation_initializers = []
      joined_users = []
      invited_users = []
      join_requests_by_user_id = {}
      @city.join_requests.each { |join_request|
        join_requests_by_user_id[join_request.user_id] = join_request
      }

      added_users.each { |added_user|
        if added_user.user_preference.automatically_join_when_invited || join_requests_by_user_id[added_user.id]
          if join_requests_by_user_id[added_user.id]
            join_requests_by_user_id[added_user.id].destroy()
          end
          joined_users << added_user
          resident_initializers << { :user_id => added_user.id, :city_id => @city.id }
        else
          invited_users << added_user
          invitation_initializers << { :user_id => added_user.id, :city_id => @city.id }
        end
      }
      Resident.create(resident_initializers)
      Invitation.create(invitation_initializers)


      InfoMailer.notify_users_added_to_game(joined_users, @city, @authorized_user)
      InfoMailer.notify_users_invited_to_game(invited_users, @city, @authorized_user)

      @city.reload()

      render json: {
          city: @city.as_json(City::JSON_OPTION_USER_ID => @authorized_user.id),
          already_joined_users: already_joined_users,
          existing_users_joined: (existing_users & joined_users),
          already_invited_users: already_invited_users,
          existing_users_invited: (existing_users & invited_users),
          new_users_joined: new_users_valid,
          new_users_invalid: new_users_invalid
      }
      return true
    else
      head :forbidden
      return false
    end
  end

  before_filter(:only => :start) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id/start', "Start a game."
  description "Start a game. Only a #{RESOURCE} creator can start it."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  def start
    user_can_create_games = @authorized_user.app_permissions.map { |app_permission| app_permission.id}.include?(AppPermission::CREATE_GAMES)
    game_purchase_to_spend = @authorized_user.game_purchases.first()

    if user_can_create_games || game_purchase_to_spend
      @city = City.find(params.require(:id))

      unless @city.user_creator_id == @authorized_user.id
        head :unauthorized
        return false
      end

      if @city.started_at.nil?
        if @city.start()
          unless user_can_create_games
            if game_purchase_to_spend.nil?
              logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())
              logger.error('User does not have permissions to create games AND he does not have game purchases available. Yet he managed to start a game.')
            end

            game_purchase_to_spend.city = @city
            game_purchase_to_spend.city_name = @city.name
            game_purchase_to_spend.city_started_at = @city.started_at
            game_purchase_to_spend.save()
          end

          city_hash = @city.as_json({City::JSON_OPTION_USER_ID => @authorized_user.id})
          user_hash = @authorized_user.as_json({User::JSON_OPTION_USER_ID => @authorized_user.id})

          render json: {:city => city_hash, :user => user_hash}
          return true
        else
          render json: @city.errors, status: :unprocessable_entity
          return false
        end

      else
        render json: 'Cannot start a game that is already started.', :status => :unprocessable_entity
        return false
      end


    else
      # user not allowed to start a game
      head :unauthorized
      return false
    end




  end

  before_filter(:only => :stop) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id/stop', "Stop a game."
  description "Stop a game. Only a #{RESOURCE} creator can stop it."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  def stop
    @city = City.find(params.require(:id))

    unless @city.user_creator_id == @authorized_user.id
      head :unauthorized
      return false
    end

    if @city.active
      @city.stop()
      render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
      return true
    else
      head :ok
      return true
    end
  end


  before_filter(:only => :pause) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id/pause', "Pause a game."
  description "Pause a game. Only a #{RESOURCE} creator can pause it."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  def pause
    @city = City.find(params.require(:id))

    unless @city.user_creator_id == @authorized_user.id
      head :unauthorized
      return false
    end

    if @city.pause()
      if @city.save
        render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
        return true
      else
        render json: @city.errors, status: :unprocessable_entity
        return false
      end

    else
      head :forbidden
      return false
    end
  end


  before_filter(:only => :resume) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id/resume', "Resume a game."
  description "Resume a game. Only a #{RESOURCE} creator can resume it."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :required => true, :desc => "A #{RESOURCE} id."
  def resume
    @city = City.find(params.require(:id))

    unless @city.user_creator_id == @authorized_user.id
      head :unauthorized
      return false
    end

    if @city.resume()
      if @city.save
        render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
      else
        render json: @city.errors, status: :unprocessable_entity
      end

      return true
    else
      render json: @city.errors, status: :unprocessable_entity
      return false
    end

  end


  # PUT /cities/1
  # PUT /cities/1.json
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  api :POST, '/cities/:city_id', "Update an existing #{RESOURCE}."
  description "Update an existing #{RESOURCE}. Example:
  #{UPDATE_CITY_DESC}
              "
  param_group :auth_required, ApipieParams::Auth
  param_group :city, ApipieParams::City
  def update
    @city = City.find(params.require(:id))

    can_admin_write = @authorized_user.app_permissions.any? {|perm| perm.id == AppPermission::ADMIN_WRITE}
    if @city.user_creator_id != @authorized_user.id && !can_admin_write
      can_admin_read = @authorized_user.app_permissions.any? {|perm| perm.id == AppPermission::ADMIN_READ}
      if can_admin_read
        param_city = params.require(:city)
        param_city = param_city.permit(:description)
        if @city.update_attributes(param_city)
          render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
          return true
        else
          render json: @city.errors, status: :unprocessable_entity
          return false
        end
      else
        head :unauthorized
        return false
      end

    end

    city_hash = City.init_hash(params.require(:city))

    if @city.started_at
      city_hash.delete(:residents)
      unless @city.paused
        city_hash.delete(:day_cycles)
      end
      city_hash.delete(:game_end_conditions)
      city_hash.delete(:city_has_roles)
      city_hash.delete(:self_generated_result_types)
      city_hash.delete(:timezone)
      city_hash.delete(:name)
      city_hash.delete(:public)

      city_hash.delete(:password)
      city_hash.delete(:hashed_password)
      city_hash.delete(:password_salt)
    end


    if @city.update_attributes(city_hash)
      render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
    else
      render json: @city.errors, status: :unprocessable_entity
    end
  end


  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization, [AppPermission::PARTICIPATE]) }
  # DELETE /cities/1
  # DELETE /cities/1.json
  api :DELETE, '/cities/:city_id', "Delete an existing #{RESOURCE}."
  description "Delete an existing #{RESOURCE}. Only an admin or a #{RESOURCE} creator can delete a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :desc => "A #{RESOURCE} id.", :required => true
  def destroy
    @city = City.find(params.require(:id))

    can_admin_write = @authorized_user.app_permissions.any? {|perm| perm.id == AppPermission::ADMIN_WRITE}
    if can_admin_write && params[:password].nil?
      @city.destroy()
      head :no_content
      return true
    end


    user = User.authenticate(@authorized_user.username, params.require(:password))

    if user.nil? || user == false
      head :unauthorized
      return false
    end

    if @city.user_creator_id == user.id
      @city.destroy
      head :no_content
      return true
    else
      head :unauthorized
      return false
    end
  end


  # used on heroku hosting to repeatedly make sure scheduler is running the cron jobs
  api :GET, '/cities/ping', "Ping all #{RESOURCE.pluralize()}."
  description "[ADMIN]. Check are the day/night jobs scheduled for all #{RESOURCE.pluralize()} that are currently active."
  param_group :auth_required, ApipieParams::Auth
  show false
  def ping
    City.ping_all_cities()
    head :ok
  end

  before_filter(:only => :trigger_day_start) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  # POST /cities/1/trigger_day_start
  # POST /cities/1/trigger_day_start.json
  api :POST, '/cities/:city_id/trigger_day_start', "Trigger day start for a #{RESOURCE}."
  description "[ADMIN]. Trigger day start for a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :desc => "A #{RESOURCE} id.", :required => true
  show false
  def trigger_day_start
    @city = City.find(params.require(:id))

    if @city.started_at && !@city.finished_at
      @city.handle_day_start()

      render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
    else
      head :unprocessable_entity
    end

  end

  before_filter(:only => :trigger_night_start) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  # POST /cities/1/trigger_night_start
  # POST /cities/1/trigger_night_start.json
  api :POST, '/cities/:city_id/trigger_night_start', "Trigger night start for a #{RESOURCE}."
  description "[ADMIN]. Trigger night start for a #{RESOURCE}."
  param_group :auth_required, ApipieParams::Auth
  param :city_id, Integer, :desc => "A #{RESOURCE} id.", :required => true
  show false
  def trigger_night_start
    @city = City.find(params.require(:id))

    if @city.started_at && !@city.finished_at
      @city.handle_night_start()
      render json: @city, City::JSON_OPTION_USER_ID => @authorized_user.id
    else
      head :unprocessable_entity
    end

  end

end
