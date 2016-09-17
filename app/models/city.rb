require_dependency 'module/city/starter'
require_dependency 'module/city/day_cycle_handler'


class City < ActiveRecord::Base
  include Module::City::Starter
  include Module::City::DayCycleHandler
  include Module::City::Validator
  include Module::City::Residents
  include Module::City::SelfGenerated
  extend Module::City::Initializer


  has_many :day_cycles, :dependent => :destroy
  has_many :residents, -> { includes [:user, :role]}, :dependent => :destroy
  has_many :actions, through: :residents
  has_many :days, :dependent => :destroy
  has_many :city_has_game_end_conditions, :dependent => :destroy
  has_many :game_end_conditions, :through => :city_has_game_end_conditions
  has_many :city_has_self_generated_result_types, :dependent => :destroy
  has_many :self_generated_result_types, :through => :city_has_self_generated_result_types, :source => :action_result_type
  has_many :city_has_roles, :dependent => :destroy
  has_many :roles, :through => :city_has_roles

  has_many :action_results, :dependent => :destroy

  belongs_to :user_creator, :foreign_key => :user_creator_id, :class_name => User.name

  has_many :invitations, :dependent => :destroy
  has_many :join_requests, :dependent => :destroy

  has_many :role_picks


  # attr_accessible :name, :user_creator_id, :timezone, :day_cycles, :active, :paused, :paused_during_day, :finished_at, :residents, :id, :city_has_roles, :self_generated_result_types, :game_end_conditions, :current_day, :started_at, :created_at, :updated_at

  attr_accessor :current_day

  accepts_nested_attributes_for :residents
  accepts_nested_attributes_for :city_has_roles, :self_generated_result_types, :game_end_conditions, :day_cycles

  validates_presence_of :name, :user_creator_id

  validate :validate_city_has_roles, :day_cycles_must_not_overlap #, :creator_must_be_resident

  before_create :set_last_accessed_at
  before_destroy :before_destroying

  def current_day(refresh)
    if @current_day == nil || refresh
      @current_day = self.days.order('days.id DESC').first
    end

    @current_day
  end


  def current_time
    time_utc = Time.now.utc
    time_utc_in_minutes = time_utc.hour * 60 + time_utc.min
    (time_utc_in_minutes + self.timezone) % (24*60)
  end

  def is_currently_daytime
    current_time = self.current_time()

    min_diff = 24*60
    earliest_moment = 24*60
    earliest_is_day_start = true
    currently_daytime = nil
    self.day_cycles.each { |day_cycle|
      if day_cycle.day_start < earliest_moment
        earliest_moment = day_cycle.day_start
        earliest_is_day_start = true
      end

      time_diff = day_cycle.day_start - current_time
      if time_diff > 0 && time_diff < min_diff
        min_diff = time_diff
        currently_daytime = false
      end

      if day_cycle.night_start < earliest_moment
        earliest_moment = day_cycle.night_start
        earliest_is_day_start = false
      end

      time_diff = day_cycle.night_start - current_time
      if time_diff > 0 && time_diff < min_diff
        min_diff = time_diff
        currently_daytime = true
      end
    }
    if currently_daytime.nil?
      currently_daytime = !earliest_is_day_start
    end

    currently_daytime
  end


  # BEGIN role quantities

  def role_quantity(role_id)
    city_has_roles = self.city_has_roles.where(:role_id => role_id)
    city_has_roles.count
  end

  # sets city's 'city_has_roles' property -> count quantity for each role based on associated residents and their roles
  # used only from seed files
  # in ordinary creation of new city, it would be the other way around: residents would be assigned their roles based on city's 'city_has_roles' property
  def set_role_quantities
    role_ids = self.residents.map { |resident| resident.role_id}.uniq()
    role_ids.each { |role_id|
      role_id_count = self.residents.select { |resident| resident.role_id == role_id}.length
      self.set_role_quantity(role_id, role_id_count)
    }

  end


  # END role quantities

  JSON_OPTION_USER_ID = 'user_id'
  JSON_OPTION_TEMP_RESIDENTS = 'temp_residents'

  def as_json(options={})
    city_hash = {
        :id => self.id,
        :name => self.name,
        :description => self.description,
        :public => self.public,
        :hashed_password => self.hashed_password,
        :password_salt => self.password_salt,
        :city_has_roles => self.city_has_roles,
        :residents => self.residents(options[JSON_OPTION_TEMP_RESIDENTS].nil?).as_json(Resident::JSON_OPTION_USER_ID => options[JSON_OPTION_USER_ID]),
        :invitations => self.invitations,
        :join_requests => self.join_requests,
        :self_generated_result_types => self.self_generated_result_types,
        :game_end_conditions => self.game_end_conditions,
        :timezone => self.timezone,
        :day_cycles => self.day_cycles,
        :user_creator_id => self.user_creator_id,
        :user_creator_username => self.user_creator.nil? ? '' : self.user_creator.username,
        :active => self.active,
        :paused => self.paused,
        :paused_during_day => self.paused_during_day,
        :last_paused_at => self.last_paused_at,
        :current_day => self.current_day(true),
        :days => self.days,
        :started_at => self.started_at,
        :finished_at => self.finished_at,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }

    user_id = options[JSON_OPTION_USER_ID]
    if user_id
      city_hash[:is_invited] = self.invitations.any? { |i| i.user_id == user_id }
      city_hash[:is_join_requested] = self.join_requests.any? { |jr| jr.user_id == user_id }
      city_hash[:is_member] = self.residents.any? {|r| r.user_id == user_id}
      city_hash[:is_owner] = self.user_creator_id == user_id

      city_hash[:role_picks] = self.role_picks.where(:user_id => user_id)
    end

    if user_id == self.user_creator_id
      city_hash[:password] = self.password
    end

    return city_hash
  end

  def set_last_accessed_at
    self.last_accessed_at = Time.now()
  end

  def before_destroying
    self.stop_day_cycle_handlers()

    if self.started_at
      self.role_picks.each { |role_pick|
        role_pick.city = nil;
      }
    else
      self.role_picks.each { |role_pick|
        role_pick.destroy()
      }
    end

  end



  protected

  def set_role_quantity(role_id, quantity)
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    city_has_role_array = self.city_has_roles.select { |city_has_role| city_has_role.role_id == role_id}
    while city_has_role_array.length < quantity
      city_has_role_array << CityHasRole.create(:city_id => self.id, :role_id => role_id)
    end
    while city_has_role_array.length > quantity
      last_city_has_role = city_has_role_array.last
      city_has_roles.remove(last_city_has_role)
      last_city_has_role.destroy()
    end

  end

  def increment_days
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    new_day = Day.new(:number => self.days.count)
    self.days << new_day
    self.save()
    @current_day = nil

    logger.info("MANUAL LOG - days incremented. Total days count #{self.days.count}.")
  end

end
