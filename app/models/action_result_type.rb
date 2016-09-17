require_dependency('static/action_result/store_results')
require_dependency('module/action_result/initializer')

class ActionResultType < ActiveRecord::Base

  VOTE = 1
  PROTECT = 2
  INVESTIGATE = 3
  VOTE_MAFIA = 4
  SHERIFF_IDENTITIES = 5
  RESIDENT_BECAME_SHERIFF = 6
  TELLER_VOTES = 7
  TERRORIST_BOMB = 8
  MAFIA_MEMBERS = 9
  RESIDENTS = 10
  JOURNALIST = 11
  DEPUTY_IDENTITIES = 12
  RESIDENT_BECAME_DEPUTY = 13
  ACTION_TYPE_PARAMS = 14
  GAME_OVER = 15
  ELDER_VOTE = 16
  REVIVAL_OCCURRED = 17
  REVIVAL_REVEALED = 18
  FORGER_VOTE = 19


  has_many :action_results

  # attr_accessible :action, :action_id, :result, :result_json, :is_automatically_generated, :city_id, :city, :resident_id, :resident, :type, :role_id, :role, :day, :day_id

  before_create :before_creating

  def before_creating
    # implement in subclasses
    self.name = 'Action Result Type'
  end

  # if action results are matching, they should never both be shown to the end user
  def matching(action_result1, action_result2)
    (action_result1.role_id == action_result2.role_id || action_result1.role_id.nil? || action_result2.role_id.nil?) &&
        action_result1.class == action_result2.class &&
        action_result1.day_id == action_result2.day_id
  end

  def action_result_will_be_created_based_on_hash(action_result_hash)
    # do nothing by default
    # action results of certain types will maybe clear the day that was being set (mafia members)
  end


  def as_json(options={})
    {
        :id => self.id,
        :name => self.name,
        :description => self.description,
        :is_self_generated => self.is_self_generated
    }
  end



end
