require_dependency "module/action_resolver/resolver"

class ActionResolver < ActiveRecord::Base
  before_create :set_ordinal

  #this is where action results are corrected in order to take into account results of other actions
  #e.g. result of doctor's protect action depends on mafia's voteForKill action, and vice-versa
  def self.resolve_action_results(valid_results_hash, void_results_hash, city, trigger_id)
    action_resolvers = self.order('ordinal ASC').all
    action_resolvers.each { |action_resolver|
      action_resolver.resolve(valid_results_hash, void_results_hash, city, trigger_id)
    }
  end

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # override in subclass
  end

  def set_ordinal
    # subclass
  end
end
