class Resident < ActiveRecord::Base
  belongs_to :role, -> { includes :affiliation}
  has_many :actions, :dependent => :destroy
  has_many :action_results, :dependent => :nullify
  has_many :can_do_action_types, :through => :role, :source => :action_types
  has_many :resident_previous_roles, :inverse_of => :resident, :dependent => :destroy
  has_many :resident_role_action_type_params_models, :dependent => :destroy


  belongs_to :city
  belongs_to :user

  # attr_accessible :user, :user_id, :city, :city_id, :role, :role_id, :saved_role_id, :alive, :role_seen

  validates_uniqueness_of :user_id, scope: [:city_id]

  before_create :before_creation

  def before_creation
    if self.name.nil?
      self.name = self.user.username
    end
  end


  JSON_OPTION_SHOW_ALL = 'show_all'
  JSON_OPTION_USER_ID = 'user_id'

  def as_json(options={})
    resident_hash = {
        :id => self.id,
        :user_id => self.user_id,
        :name => self.name,
        :username => self.user ? self.user.username : nil,
        :city_id => self.city.id,
        :city_name => self.city.name
    }

    if options[JSON_OPTION_USER_ID] && self.user_id == options[JSON_OPTION_USER_ID] && self.city.started_at
      unless self.role_seen
        self.saved_role_id = self.role_id
        self.role_seen = true
        self.save()
      end
      resident_hash[:saved_role_id] = self.saved_role_id
      saved_role = Role.where(:id => self.saved_role_id).first()
      resident_hash[:saved_role] = (saved_role || {}).as_json()
    end

    if options[JSON_OPTION_SHOW_ALL]
      resident_hash[:role] = self.role.as_json()
      resident_hash[:role_seen] = self.role_seen
      resident_hash[:saved_role_id] = self.saved_role_id
      resident_hash[:alive] = self.alive
      resident_hash[:died_at] = self.died_at
      resident_hash[:updated_at] = self.updated_at
    end

    resident_hash
  end
end