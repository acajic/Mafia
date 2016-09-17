module Module::City::Starter

  def start
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    increment_days()
    residents_without_user = self.residents.any? {|resident| resident.user_id.nil? }
    if residents_without_user
      self.errors.add(:residents, 'There are some residents (i.e. ' + residents_without_user.map{|r| r.name}.join(', ') + ') that link to deleted user accounts. Kick those players and try again.')
    end

    unless validate_roles_distribution()
      self.errors.add(:city_has_roles, 'Two opposing affiliations must be represented in role distribution')
    end

    if self.errors.count > 0
      logger.info('MANUAL LOG - errors: ' + self.errors.as_json())
      return false
    end

    if distribute_roles()
      init_self_generated_results()
      start_day_cycle_handlers()
      self.active = true
      self.started_at = Time.now.utc

      if self.save()
        self.role_picks(true).each { |role_pick|
          role_pick.city_started_at = self.started_at
          role_pick.save()
        }

        self.invitations.destroy_all()
        self.join_requests.destroy_all()
        return true
      else
        return false
      end
    else
      self.errors.add(:city_has_roles, 'City must define proper role distribution before starting.')
      return false
    end
  end

  def stop
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    stop_day_cycle_handlers()
    self.active = false
    self.finished_at = Time.now.utc
    self.save!
  end

  def pause
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if self.active
      self.paused = true
      self.paused_during_day = is_currently_daytime()
      self.last_paused_at = Time.now.utc

      stop_day_cycle_handlers()
      return true
    else
      return false
    end

  end

  def resume
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if self.active && self.paused
      if self.paused_during_day == is_currently_daytime()
        self.paused = false
        self.paused_during_day = nil
        start_day_cycle_handlers()
        return true
      else
        self.errors[:base] << "Game was paused during #{ self.paused_during_day ? "daytime" : "night time" }. It can only be resumed during #{ self.paused_during_day ? "daytime" : "night time" }."
        return false
      end
    else
      return false
    end

  end

  def validate_roles_distribution
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    roles_count = {}
    demanded_roles_min_count_per_residents = {}
    demanded_roles_min_count_total = {}
    demanded_roles_max_count_per_residents = {}
    demanded_roles_max_count_total = {}

    citizens_affiliation_represented = false
    mafia_affiliation_represented = false

    self.city_has_roles.each { |city_has_role|
      unless citizens_affiliation_represented
        citizens_affiliation_represented = city_has_role.role.affiliation_id == Affiliation::CITIZENS
      end
      unless mafia_affiliation_represented
        mafia_affiliation_represented = city_has_role.role.affiliation_id == Affiliation::MAFIA
      end

      if roles_count[city_has_role.role_id].nil?
        roles_count[city_has_role.role_id] = 0
      end
      roles_count[city_has_role.role_id] += 1

      city_has_role.role.role_has_demanded_roles.each { |role_has_demanded_role|
        if demanded_roles_min_count_per_residents[role_has_demanded_role.demanded_role_id].nil?
          demanded_roles_min_count_per_residents[role_has_demanded_role.demanded_role_id] = 0
        end


        if role_has_demanded_role.is_demanded_per_resident
          demanded_roles_min_count_per_residents[role_has_demanded_role.demanded_role_id] += role_has_demanded_role.quantity_min

          if demanded_roles_max_count_per_residents[role_has_demanded_role.demanded_role_id].nil? && role_has_demanded_role.quantity_max
            demanded_roles_max_count_per_residents[role_has_demanded_role.demanded_role_id] = role_has_demanded_role.quantity_max
          elsif role_has_demanded_role.quantity_max
            demanded_roles_max_count_per_residents[role_has_demanded_role.demanded_role_id] += role_has_demanded_role.quantity_max
          end

        else
          if demanded_roles_min_count_total[role_has_demanded_role.demanded_role_id].nil?
            demanded_roles_min_count_total[role_has_demanded_role.demanded_role_id] = 0
          end
          demanded_roles_min_count_total = [demanded_roles_min_count_total, role_has_demanded_role.quantity_min].max()

          if demanded_roles_max_count_total[role_has_demanded_role.demanded_role_id].nil?
            demanded_roles_max_count_total[role_has_demanded_role.demanded_role_id] = 1000000 # very large number
          end
          demanded_roles_max_count_total = [demanded_roles_max_count_total, role_has_demanded_role.quantity_max].min()

        end
      }

    }


    roles_count.each_pair { |role_id, count|
      demanded_min = [demanded_roles_min_count_per_residents[role_id] || 0, demanded_roles_min_count_total[role_id] || 0].max()
      demanded_max = [demanded_roles_max_count_per_residents[role_id] || 1000000, demanded_roles_max_count_total[role_id] || 1000000].min()

      if count < demanded_min
        return false
      end
      if count > demanded_max
        return false
      end
    }



    citizens_affiliation_represented && mafia_affiliation_represented
  end



  def distribute_roles
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    if self.residents.count != self.city_has_roles.count
      return false
    end

    city_has_roles_by_role_ids = {}
    self.city_has_roles.each { |city_has_role|
      if city_has_roles_by_role_ids[city_has_role.role_id].nil?
        city_has_roles_by_role_ids[city_has_role.role_id] = []
      end

      city_has_roles_by_role_ids[city_has_role.role_id] << city_has_role
    }

    residents_by_user_ids = {}
    self.residents.each { |resident|
      residents_by_user_ids[resident.user_id] = resident
    }

    disregarded_role_picks = []
    disregarded_role_picks.push(*(self.role_picks.to_a()))

    self.role_picks.order('created_at ASC').each { |role_pick|
      resident = residents_by_user_ids[role_pick.user_id]
      if resident.nil?
        next # this means that user was already assigned the role they requested
      end

      if resident.user.unused_role_pick_purchases.count == 0
        next
      end

      if (city_has_roles_by_role_ids[role_pick.role_id] || []).count == 0
        next
      end

      residents_by_user_ids.delete(resident.user_id) # this resident is about be assigned a role, so he gets removed

      role_pick_purchase = resident.user.unused_role_pick_purchases.first()
      role_pick_purchase.role_pick = role_pick # mark role_pick_purchase as 'used'
      disregarded_role_picks.delete(role_pick)

      role_pick_purchase.save()

      city_has_role = city_has_roles_by_role_ids[role_pick.role_id].delete_at(0) # this city_has_role has been assigned

      assign_city_has_role_to_resident(resident, city_has_role)
    }

    disregarded_role_picks.each{ |disregarded_role_pick|
      disregarded_role_pick.destroy()
    }

    unassigned_city_has_roles = []
    city_has_roles_by_role_ids.each_pair { |role_id, city_has_roles|
      unassigned_city_has_roles.concat(city_has_roles) # re-collect all city_has_roles that have not been assigned via role_picks
    }

    residents_by_user_ids.each_pair { |user_id, resident|
      random_city_has_role = unassigned_city_has_roles.delete_at(rand(unassigned_city_has_roles.length))

      assign_city_has_role_to_resident(resident, random_city_has_role)
    }

    true
  end





  def init_self_generated_results
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    trigger_id = nil
    if self.is_currently_daytime()
      trigger_id = Trigger::DAY_START
    else
      trigger_id = Trigger::NIGHT_START
    end

    valid_results_hash = self.self_generated_results(self.current_day(true), trigger_id)

    ::ActionResolver.resolve_action_results(valid_results_hash, {}, self, trigger_id) # method declared in Module::ActionResolver::Resolver
    action_result_initializers = self.action_result_initializers_from_hash(valid_results_hash)
    ActionResult.create(action_result_initializers)
  end

  def init_action_type_params
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    resident_role_action_type_params_initializers = []

    city_has_roles = CityHasRole.includes(:role => :role_has_action_types).where(:city_id => self.id)

    self.residents.each { |resident|
      city_has_roles.each { |city_has_role|
        city_has_role.role.role_has_action_types.each { |role_has_action_type|
          unless role_has_action_type.action_type_params.nil? || role_has_action_type.action_type_params.empty?
            resident_role_action_type_params_initializers << {:resident_id => resident.id, :role_id => city_has_role.role_id, :action_type_id => role_has_action_type.action_type_id, :action_type_params_hash => role_has_action_type.action_type_params}
          end
        }
      }
    }

    ResidentRoleActionTypeParamsModel.create(resident_role_action_type_params_initializers)
  end

  def start_day_cycle_handlers
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    scheduler = AppConfig.instance.scheduler

    logger.info('MANUAL LOG - scheduler: ' + scheduler.to_s())

    self.stop_day_cycle_handlers()

    utc_offset = Time.new.utc_offset / 60

    self.day_cycles.each { |dayCycle|
      logger.info('MANUAL LOG - day_cycle: ' + dayCycle.to_json())

      day_start = (dayCycle.day_start + utc_offset - self.timezone + (24*60)) % (24*60)
      night_start = (dayCycle.night_start + utc_offset - self.timezone + (24*60)) % (24*60)

      logger.info('MANUAL LOG - creating cron job. Start: ' + (day_start / 60).to_s() + ':' + (day_start%60).to_s() + '; End: ' + (night_start / 60).to_s() + ':' +  (night_start%60).to_s())

      result = scheduler.cron("#{day_start % 60} #{day_start / 60} * * *", {:tags => scheduler_tag}) {
        ActiveRecord::Base.connection_pool.with_connection {
          dayCycle.city.handle_day_start()
        }
      }

      result = scheduler.cron("#{night_start % 60} #{night_start / 60} * * *", {:tags => scheduler_tag}) {
        ActiveRecord::Base.connection_pool.with_connection {
          dayCycle.city.handle_night_start()
        }
      }

      logger.info('MANUAL LOG - created cron job. Start: ' + (day_start / 60).to_s() + ':' + (day_start%60).to_s() + '; End: ' + (night_start / 60).to_s() + ':' +  (night_start%60).to_s())

    }
  end

  def stop_day_cycle_handlers
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    scheduler = AppConfig.instance.scheduler
    jobs = scheduler.jobs(:tag => scheduler_tag)
    jobs.each { |job|
      job.unschedule()
      logger.info('MANUAL LOG - job stopped: ' + job.to_s())
    }

  end

  def detect_game_end
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    is_game_over = false

    self.game_end_conditions.each { |game_end_condition|
      if game_end_condition.check_game_end(self)
        self.stop_day_cycle_handlers()
        is_game_over = true
        break
      end
    }

    is_game_over
  end

  def scheduler_tag
    "#{self.class}#{self.id}"
  end



  private

  def assign_city_has_role_to_resident(resident, city_has_role)
    resident.role_id = city_has_role.role_id
    resident.save()


    if city_has_role.action_types_params
      city_has_role.action_types_params.each_pair { |action_type_id, action_type_params|
        unless action_type_params.nil? || action_type_params.empty?
          ResidentRoleActionTypeParamsModel.create(:resident => resident, :role => city_has_role.role, :action_type_id => action_type_id, :action_type_params_hash => action_type_params)
        end
      }
    end
  end

end