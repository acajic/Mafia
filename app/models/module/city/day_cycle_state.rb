module Module::City::DayCycleState

  def is_currently_daytime
    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    nearest_future_moment = {
        :time => 0,
        :is_day_start => false
    }

    current_time = Time.now().utc + self.timezone.minutes
    current_time_minutes = current_time.hour * 60 + current_time.min

    self.day_cycles.each { |day_cycle|

      diff = (day_cycle.day_start + 24*60 - current_time_minutes) % (24*60)
      if day_cycle.day_start < nearest_future_moment.time
        nearest_future_moment.time = day_cycle.day_start
        nearest_future_moment.is_day_start = true
      end

      diff = (day_cycle.night_start + 24*60 - current_time_minutes) % (24*60)
      if day_cycle.night_start < nearest_future_moment.time
        nearest_future_moment.time = day_cycle.night_start
        nearest_future_moment.is_day_start = false
      end
    }

    !nearest_future_moment.is_day_start
  end



end