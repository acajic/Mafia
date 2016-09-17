class ActionResolver::RevivalOccurredSelfGeneratedResidents < ActionResolver


  def resolve(valid_results_hash, void_results_hash, city, trigger_id)

    # hide that a certain resident is revived
    # alter SelfGenerated::Residents results

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    revive_resident_ids = []
    if valid_results_hash[ActionResultType::RevivalOccurred]
      valid_results_hash[ActionResultType::RevivalOccurred].each { |revival_occurred_valid_result_hash|
        revive_action = revival_occurred_valid_result_hash[:action]
        revived_resident_id = revive_action.input[ActionType::Revive::KEY_TARGET_ID]



        days_until_reveal = revive_action.action_type_params.action_type_params_hash[ActionType::Revive::PARAM_DAYS_UNTIL_REVEAL]
        if days_until_reveal > 0
          revive_resident_ids << revive_action.input[ActionType::Revive::KEY_TARGET_ID]
        else
          unless valid_results_hash[ActionResultType::RevivalRevealed]
            valid_results_hash[ActionResultType::RevivalRevealed] = []
          end

          valid_results_hash[ActionResultType::RevivalRevealed] << {
              :action => revive_action,
              :action_result_type_id => ActionResultType::REVIVAL_REVEALED,
              :city_id => city.id,
              :resident_id => nil,
              :role_id => nil,
              # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
              :result => { ActionResultType::RevivalRevealed::KEY_TARGET_ID => revived_resident_id },
              :is_automatically_generated => true
          }


          add_zombie_to_mafia_members_results(revived_resident_id, valid_results_hash, void_results_hash, city)

        end

      }
    end

    action_results_revive_occurred = city.action_results.where(:action_result_type_id => ActionResultType::REVIVAL_OCCURRED, :is_automatically_generated => true).to_a()
    action_results_revive_occurred.delete_if { |action_result_revive_occurred|
      action_results_revive_revealed = city.action_results.where(:action_result_type_id => ActionResultType::REVIVAL_REVEALED, :action_id => action_result_revive_occurred.action.id)
      action_results_revive_revealed.count > 0
    }


    active_action_results_revive_occurred = action_results_revive_occurred.select { |action_result_revive_occurred|
      days_until_reveal = action_result_revive_occurred.action.action_type_params.action_type_params_hash[ActionType::Revive::PARAM_DAYS_UNTIL_REVEAL]

      day_difference = city.current_day(false).number - action_result_revive_occurred.day.number
      action_type_revive =  ActionType.find(ActionType::REVIVE)

      day_difference < days_until_reveal || (day_difference == days_until_reveal && trigger_id != action_type_revive.trigger_id)
    }
    revive_resident_ids += active_action_results_revive_occurred.map { |action_result_revive_occurred|
      action_result_revive_occurred.action.input[ActionType::Revive::KEY_TARGET_ID]
    }
    revive_resident_ids.uniq!



    if revive_resident_ids.count > 0
      public_valid_residents_result = nil
      valid_results_hash[ActionResultType::SelfGenerated::Residents].each { |valid_residents_result| # valid self generated residents result
        if valid_residents_result[:resident_id].nil?
          public_valid_residents_result = valid_residents_result
        end

        resident_statuses = valid_residents_result[:result][ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS]
        resident_statuses.each { |resident_status|
          if revive_resident_ids.include?(resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID])
            resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE] = false
          end
        }
      }

      if public_valid_residents_result
        revive_resident_ids.each { |revived_resident_id|
          result_hash = public_valid_residents_result[:result].deep_dup()
          result_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS].each { |resident_status|
            if resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == revived_resident_id
              resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE] = true
            end
          }

          valid_results_hash[ActionResultType::SelfGenerated::Residents] << {:action => nil,
                                                                             :action_result_type_id => ActionResultType::RESIDENTS,
                                                                             :city_id => city.id,
                                                                             :resident_id => revived_resident_id,
                                                                             :role_id => nil,
                                                                             # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
                                                                             :result => result_hash,
                                                                             :is_automatically_generated => true}
        }

      end

    end


    expired_action_results_revive_occurred = action_results_revive_occurred - active_action_results_revive_occurred
    expired_action_results_revive_occurred.each { |expired_action_result_revive_occurred|
      unless valid_results_hash[ActionResultType::RevivalRevealed]
        valid_results_hash[ActionResultType::RevivalRevealed] = []
      end

      revived_resident_id = expired_action_result_revive_occurred.action.input[ActionType::Revive::KEY_TARGET_ID]

      valid_results_hash[ActionResultType::RevivalRevealed] << {
          :action => expired_action_result_revive_occurred.action,
          :action_result_type_id => ActionResultType::REVIVAL_REVEALED,
          :city_id => city.id,
          :resident_id => nil,
          :role_id => nil,
          # no need to set :day property, it is being set from Module::City::DayCycleHandler using Module::ActionResult::StoreResults
          :result => { ActionResultType::RevivalRevealed::KEY_TARGET_ID => revived_resident_id },
          :is_automatically_generated => true
      }


      add_zombie_to_mafia_members_results(revived_resident_id, valid_results_hash, void_results_hash, city)
    }
  end


  def add_zombie_to_mafia_members_results(zombie_resident_id, valid_results_hash, void_results_hash, city)

    mafia_members_results = city.action_results
    .where('action_results.action_result_type_id = ?', ActionResultType::MAFIA_MEMBERS)
    .order('action_results.id DESC')

    residents = city.residents.to_a()
    resident_ids = residents.map {|r| r.id}
    residents_by_id = {}
    residents.each { |resident|
      residents_by_id[resident.id] = resident
    }



    active_mafia_members_result_per_resident = {}
    mafia_members_results.each { |valid_mafia_members_result|
      if active_mafia_members_result_per_resident[valid_mafia_members_result.resident_id].nil?
        active_mafia_members_result_per_resident[valid_mafia_members_result.resident_id] = valid_mafia_members_result
      end
    }


    if valid_results_hash[ActionResultType::SingleRequired::MafiaMembers].nil?
      valid_results_hash[ActionResultType::SingleRequired::MafiaMembers] = []
    end
    if void_results_hash[ActionResultType::SingleRequired::MafiaMembers].nil?
      void_results_hash[ActionResultType::SingleRequired::MafiaMembers] = []
    end



    active_mafia_members_result_per_resident.each_pair { |resident_id, active_mafia_members_result|
      if active_mafia_members_result.nil? || active_mafia_members_result.is_automatically_generated

        mafia_member_ids = active_mafia_members_result.result[ActionResultType::SingleRequired::MafiaMembers::KEY_MAFIA_MEMBERS]
        if mafia_member_ids.include?(zombie_resident_id)
          not_already_picked = resident_ids - mafia_member_ids
          if not_already_picked.count > 0
            mafia_member_ids << not_already_picked.sample()
          end
        else
          mafia_member_ids << zombie_resident_id
        end

        
        resident = residents_by_id[resident_id]
        results_hash = resident.role.affiliation_id == Affiliation::MAFIA ? valid_results_hash : void_results_hash

        results_hash[ActionResultType::SingleRequired::MafiaMembers] << {
            :action => nil,
            :action_result_type_id => ActionResultType::MAFIA_MEMBERS,
            :city_id => city.id,
            :resident_id => resident_id,
            :role_id => nil,
            # no need to set :day property, it should be nil for this ActionResult
            :result => {ActionResultType::SingleRequired::MafiaMembers::KEY_MAFIA_MEMBERS => mafia_member_ids},
            :is_automatically_generated => true
        }
      end
    }
  end


  def set_ordinal
    self.ordinal = 1201
  end
end