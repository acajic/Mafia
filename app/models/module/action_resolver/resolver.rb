module Module::ActionResolver::Resolver

  #this is where action results are corrected in order to take into account results of other actions
  #e.g. result of doctor's protect action depends on mafia's voteForKill action, and vice-versa
  def resolve_action_results(valid_results_hash, void_results_hash, city, trigger_id)
    action_resolvers = ::ActionResolver.order('ordinal ASC')
    action_resolvers.each { |action_resolver|
      action_resolver.resolve(valid_results_hash, void_results_hash, city, trigger_id)
    }
  end
end