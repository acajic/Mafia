class ActionResolver::DeputyIdentitiesSelfGeneratedResidents < ActionResolver

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # deputy identities vs. self generated residents

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    unless valid_results_hash[ActionResultType::DeputyIdentities].nil? || valid_results_hash[ActionResultType::SelfGenerated::Residents].nil?

      generic_self_generated_residents = nil
      self_generated_residents_per_resident_id = {}
      valid_results_hash[ActionResultType::SelfGenerated::Residents].each { |self_generated_residents_result_hash|
        if self_generated_residents_result_hash[:resident_id].nil?
          generic_self_generated_residents = self_generated_residents_result_hash
        else
          self_generated_residents_per_resident_id[self_generated_residents_result_hash[:resident_id]] = self_generated_residents_result_hash
        end

      }

      result_hashes_for_delete = []

      valid_results_hash[ActionResultType::DeputyIdentities].each { |valid_result_hash|
        unless valid_result_hash[:result][ActionResultType::DeputyIdentities::KEY_SUCCESS]
          next
        end

        action = valid_result_hash[:action]


        action.resident.reload
        unless action.resident.alive
          result_hashes_for_delete << valid_result_hash
        end

        resident_previous_role = action.resident.resident_previous_roles.order('created_at DESC').first()
        start_of_watch = nil
        if resident_previous_role == nil
          start_of_watch = action.city.created_at
        else
          start_of_watch = resident_previous_role.created_at
        end

        residents_died_on_users_watch = action.city.residents.where('died_at > ?', start_of_watch)

        dead_residents_roles = []
        self_generated_residents_result_hash = self_generated_residents_per_resident_id[action.resident_id]
        if self_generated_residents_result_hash.nil?
          self_generated_residents_result_hash = generic_self_generated_residents
        end
        residents_alive_statuses = self_generated_residents_result_hash[:result][ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS]
        residents_died_on_users_watch.each { |resident|
          count = residents_alive_statuses.count { |resident_hash| resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == resident.id && !(resident_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE]) }
          if count > 0
            dead_residents_roles << {ActionResultType::SheriffIdentities::KEY_RESIDENT_ID => resident.id, ActionResultType::SheriffIdentities::KEY_RESIDENT_ROLE_ID => resident.role_id}
          end
        }

        valid_result_hash[:result][ActionResultType::DeputyIdentities::KEY_DEAD_RESIDENTS_ROLES] = dead_residents_roles
      }
    end

    unless result_hashes_for_delete.nil?
      result_hashes_for_delete.each { |result_hash_for_delete|
        valid_results_hash[ActionResultType::DeputyIdentities].delete(result_hash_for_delete)
      }
    end

    unless void_results_hash[ActionResultType::DeputyIdentities].nil?
      void_results_hash[ActionResultType::DeputyIdentities].each { |void_result_hash|
        unless void_result_hash[:result][ActionResultType::DeputyIdentities::KEY_SUCCESS]
          next
        end

        action = void_result_hash[:action]

        start_of_watch = city.days.sample.created_at


        residents_died_on_users_watch = action.city.residents.where("died_at > ?", start_of_watch)

        city_residents = void_result_hash[:action].city.residents
        city_roles = city_residents.map { |resident| resident.role }
        dead_residents_roles = []

        total_mafia_count = city_roles.select { |role| role.affiliation_id == Affiliation::MAFIA }.length
        mafia_count = 0

        city_roles.delete_if {|role| action.role_id == role.id}
        residents_died_on_users_watch.each { |resident|
          random_role = city_roles.delete_at(rand(city_roles.length))
          while random_role.affiliation_id == Affiliation::MAFIA && mafia_count + 1 >= total_mafia_count # making sure that fake sheriff doesn't report that all mafia memebers are dead
            random_role = city_roles.delete_at(rand(city_roles.length))
          end
          dead_residents_roles << {ActionResultType::DeputyIdentities::KEY_RESIDENT_ID => resident.id, ActionResultType::DeputyIdentities::KEY_RESIDENT_ROLE_ID => random_role.id}
        }

        void_result_hash[:result][ActionResultType::DeputyIdentities::KEY_DEAD_RESIDENTS_ROLES] = dead_residents_roles

      }
    end

    # / deputy identities vs. self generated residents
  end

  def set_ordinal
    self.ordinal = 1506
  end

end