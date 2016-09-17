require('digest/sha2')

class User < ActiveRecord::Base
  has_many :auth_tokens
  belongs_to :default_app_role, :foreign_key => :default_app_role_id, :class_name => AppRole.name
  has_many :granted_app_roles, :dependent => :destroy
  # has_many :app_permissions, :through => :default_app_role
  has_many :residents
  has_many :cities_created, :class_name => City.name, :foreign_key => :user_creator_id, :inverse_of => :user_creator, :dependent => :destroy

  has_one :user_preference

  has_many :invitations, :dependent => :destroy
  has_many :join_requests, :dependent => :destroy

  has_many :payment_logs, :dependent => :nullify
  has_many :subscription_purchases, :dependent => :nullify
  has_many :game_purchases, :dependent => :nullify
  has_many :role_pick_purchases, :dependent => :nullify

  has_many :role_picks, :dependent => :destroy

  has_many :unused_role_pick_purchases, ->(user) { where(user_id: user.id, role_pick_id: nil) }, class_name: RolePickPurchase.name


  attr_accessor :password, :repeat_password, :auth_token

  attr_accessor :app_role, :app_permissions



  validates :username, :presence => true, :uniqueness => true
  validates_presence_of :password, :on => :create
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_uniqueness_of :email



  before_create :create_hashed_password
  # after_save :send_email_and_clear_password

  before_create :set_app_role
  before_create :set_user_preference
  before_create :assign_previous_purchases
  before_save :set_email_confirmation_code


  before_destroy :before_destroying


  def app_permissions(refresh=false)
    if @app_permissions.nil? || refresh
      @app_permissions = self.app_role().app_permissions
    end

    @app_permissions
  end

  def app_role(refresh=false)
    if @app_role.nil? || refresh
      last_granted_app_role = self.granted_app_roles.where('expiration_date >= ?', Time.now.to_datetime()).order('created_at DESC').first()
      if last_granted_app_role
        @app_role = last_granted_app_role.app_role
      else
        @app_role = self.default_app_role
      end
    end

    @app_role
  end

  #def unused_role_pick_purchases
  #  self.role_pick_purchases.where(:role_pick_id => nil).order('created_at ASC')
  #end


  def self.authenticate(username='', password='', identifier_url='')
    AuthToken.remove_expired_tokens()

    user = User.find_by_username(username)
    if user && Static::PasswordUtility.check_password(password, user.password_salt, user.hashed_password)
      user.auth_token = AuthToken.create(:user => user)
      user.auth_tokens << user.auth_token
      user.save()
      return user
    elsif user && identifier_url && user.identifier_url == identifier_url
      user.auth_token = AuthToken.create(:user => user)
      user.auth_tokens << user.auth_token
      user.save()
      return user
    else
      false
    end
  end



  def before_destroying
    residents_to_delete = Resident.joins(:city).where('cities.started_at IS NULL').where(:user_id => self.id)
    residents_to_delete.destroy_all()

    residents_to_nullify = Resident.where(:user_id => self.id)
    residents_to_nullify.update_all(:user_id => nil)

  end


  JSON_OPTION_SHOW_ALL = 'show_all'
  JSON_OPTION_USER_ID = 'user_id'

  def as_json(options={})
    user_hash = {
        :id => self.id,
        :username => self.username,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }

    if options[JSON_OPTION_SHOW_ALL]
      user_hash[:email_confirmed] = self.email_confirmed
      user_hash[:email_confirmation_code_exchanged] = self.email_confirmation_code_exchanged
      user_hash[:default_app_role] = self.default_app_role
    end

    if options[JSON_OPTION_USER_ID] == self.id || options[JSON_OPTION_SHOW_ALL]
      user_hash[:email] = self.email
      user_hash[:user_preference] = self.user_preference
      user_hash[:app_role] = self.app_role(true)
      user_hash[:hashed_password] = self.hashed_password
      user_hash[:password_salt] = self.password_salt

      user_hash[:auth_token] = self.auth_token
      user_hash[:role_picks] = self.role_picks


      user_hash[:game_purchases] = self.game_purchases
      user_hash[:unused_game_purchases] = self.game_purchases.where(:city_id => nil)
      user_hash[:role_pick_purchases] = self.role_pick_purchases
      user_hash[:unused_role_pick_purchases] = self.role_pick_purchases.where(:role_pick_id => nil)
      user_hash[:subscription_purchases] = self.subscription_purchases
      user_hash[:active_subscription] = self.subscription_purchases.where('expiration_date >= ?', Time.now.to_datetime()).order('created_at DESC').first()

    end

    user_hash
  end


  def user_preference
    user_pref = super
    if user_pref.nil?
      self.user_preference = UserPreference.new()
      self.save()
    end
    user_pref
  end


  private

  def create_hashed_password
    self.password_salt = self.username
    unless password.blank?
      self.hashed_password = Static::PasswordUtility.generate_hashed_password(password, self.password_salt)
    end
  end


  def set_app_role
    if User.where(:default_app_role_id => AppRole::SUPER_ADMIN).any?
      app_role = InitialAppRole.app_role_for_email(self.email)

      self.default_app_role = app_role
    else
      self.default_app_role_id = AppRole::SUPER_ADMIN
    end
  end


  def assign_previous_purchases
    self.payment_logs << PaymentLog.where(:user_email => self.email)
    self.subscription_purchases << SubscriptionPurchase.where(:user_email => self.email)
    self.game_purchases << GamePurchase.where(:user_email => self.email)
    self.role_pick_purchases << RolePickPurchase.where(:user_email => self.email)
  end


  def set_user_preference
    self.user_preference = UserPreference.new()
    if Mafia::Application.config.require_email_verification
      # do nothing
    else
      self.user_preference.receive_notifications_when_added_to_game = false
    end
    true
  end



  def set_email_confirmation_code
    if self.email_confirmation_code.nil?
      self.email_confirmation_code = rand(36**16).to_s(36)
    end
  end


end
