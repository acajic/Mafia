class UserPreferenceController < ApplicationController

  RESOURCE = 'User Preference'

  resource_description do
    short "Mostly account and mailing preferences."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "Mostly account and mailing preferences."
  end


  before_filter(:only => :update_my_user_preference) { |controller| controller.send(:confirm_authorization) }
  # GET /user_preference/me
  # GET /user_preference/me.json
  api :GET, '/user_preference/me', "Get my #{RESOURCE.pluralize()}."
  description "Get my #{RESOURCE.pluralize()}."
  param :receive_notifications_when_added_to_game, %w[true false], :required => false, :desc => 'Update whether you want to receive an email notification when someone adds you to their game. Default is true.'
  param :automatically_join_when_invited, %w[true false], :required => false, :desc => 'Update whether you want to automatically be joined to the game when someone invites you. Default is true.'
  def update_my_user_preference
    receive_notifications_when_added_to_game = params[:receive_notifications_when_added_to_game]
    unless receive_notifications_when_added_to_game.blank?
      receive_notifications_when_added_to_game = receive_notifications_when_added_to_game == :true
      if @authorized_user.user_preference
        @authorized_user.user_preference.receive_notifications_when_added_to_game = receive_notifications_when_added_to_game
      end
    end

    automatically_join_when_invited = params[:automatically_join_when_invited]
    unless automatically_join_when_invited.blank?
      automatically_join_when_invited = automatically_join_when_invited == :true
      if @authorized_user.user_preference
        @authorized_user.user_preference.automatically_join_when_invited = automatically_join_when_invited
      end
    end

    default_client_host = InfoMailer::CLIENT_HOST

    if @authorized_user.user_preference.save()
      redirect_to(default_client_host + '/user_preference_changed/' + @authorized_user.hashed_password)
      return true
    else
      render json: @authorized_user.user_preference.errors, :status => :unprocessable_entity
      return false
    end


  end


  # POST /user_preference/unsubscribe
  # POST /user_preference/unsubscribe.json
  api :GET, '/user_preference/unsubscribe', "Unsibscribe from all emails."
  description "Unsibscribe from all emails."
  param :email, String, :required => true, :desc => "An email address that whishes to be unsubscribed."
  def unsubscribe
    email = params.require(:email)

    user = User.where(:email => email).first
    if user.nil?
      render json: "No user with email '#{email}'", :status => :unprocessable_entity
      return false
    end

    user.user_preference.receive_notifications_when_added_to_game = false
    if user.user_preference.save()
      head :no_content
    else
      render json: user.user_preference.errors, :status => :unprocessable_entity
    end

  end

end
