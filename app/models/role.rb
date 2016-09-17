class Role < ActiveRecord::Base
  belongs_to :affiliation
  has_many :residents
  has_many :role_has_action_types
  has_many :action_types, :through => :role_has_action_types

  has_many :role_picks

  has_many :role_has_demanded_roles, :inverse_of => :role
  has_many :demanded_roles, :through => :role_has_demanded_roles

  has_many :role_has_implicated_roles, :inverse_of => :role
  has_many :implicated_roles, :through => :role_has_implicated_roles


  CITIZEN = 1
  DOCTOR = 2
  DETECTIVE = 3
  MOB = 4
  SHERIFF = 5
  TELLER = 6
  TERRORIST = 7
  JOURNALIST = 8
  FUGITIVE = 9
  DEPUTY = 10
  ELDER = 11
  NECROMANCER = 12
  ZOMBIE = 13
  FORGER = 14

  before_create :before_creation

  JSON_OPTION_SKIP_DEMANDED_ROLES = 'follow_demanded_roles'
  JSON_OPTION_SKIP_IMPLICATED_ROLES = 'follow_implicated_roles'

  def as_json(options={})
    role_hash = {
        :id => self.id,
        :affiliation => self.affiliation,
        :action_types => self.action_types,
        :name => self.name,
        :is_starting_role => self.is_starting_role
    }

    unless options[JSON_OPTION_SKIP_DEMANDED_ROLES]
      role_hash[:role_has_demanded_roles] = self.role_has_demanded_roles
    end

    unless options[JSON_OPTION_SKIP_IMPLICATED_ROLES]
      role_hash[:implicated_roles] = self.implicated_roles(true).as_json(Role::JSON_OPTION_SKIP_DEMANDED_ROLES => true, Role::JSON_OPTION_SKIP_IMPLICATED_ROLES => true)
    end

    role_hash
  end

  def before_creation
    # implement in subclass
  end

end
