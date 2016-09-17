module Module::City::Validator



  def creator_must_be_resident
    unless self.residents.any?{ |r| r.user_id == self.user_creator_id }
      errors.add(:residents, 'Residents must contain the user-creator')
    end
  end

  def minimum_number_of_residents
    residents_count_valid = self.residents.count >= 3

    unless residents_count_valid
      errors.add(:residents, 'Residents must contain at least 3 players')
    end
  end




  def validate_city_has_roles
    if self.active && self.city_has_roles.count != self.residents.length
      errors.add(:city_has_roles, 'Role distribution does not match the number of residents')
    end

    self.city_has_roles.includes(:role => :action_types).each { |city_has_role|
      if city_has_role.action_types_params.nil?
        next
      end

      valid = true
      city_has_role.role.action_types.each { |action_type|
        valid = action_type.params_valid(city_has_role.action_types_params[action_type.id])
        unless valid
          break
        end
      }
      unless valid
        errors.add(:city_has_roles, 'Incorrect format for action_types_params')
        break
      end
    }
  end


  def day_cycles_must_not_overlap
    day_cycles = self.day_cycles.to_a()

    generic_message = 'Minimum duration for day or night is 4 minutes.'

    for i in 0..day_cycles.count-1
      day_cycle = day_cycles[i]
      if minutes_diff(day_cycle.day_start, day_cycle.night_start) < 4
        errors.add(:day_cycles, 'Day cycles are overlapping. One day starts at ' + minutes_to_string(day_cycle.day_start) + ' and ends at ' + minutes_to_string(day_cycle.night_start) + '. ' + generic_message)
        return
      end
      for j in 0..(i-1)
        other_day_cycle = day_cycles[j]
        if minutes_diff(day_cycle.day_start, other_day_cycle.day_start) < 4
          errors.add(:day_cycles, 'Day cycles are overlapping. One day starts at ' + minutes_to_string(day_cycle.day_start) + ' and other starts at ' + minutes_to_string(other_day_cycle.day_start) + '. ' + generic_message)
          return
        end
        if minutes_diff(day_cycle.day_start, other_day_cycle.night_start) < 4
          errors.add(:day_cycles, 'Day cycles are overlapping. One day starts at ' + minutes_to_string(day_cycle.day_start) + ' and other ends at ' + minutes_to_string(other_day_cycle.night_start) + '. ' + generic_message)
          return
        end
        if minutes_diff(day_cycle.night_start, other_day_cycle.day_start) < 4
          errors.add(:day_cycles, 'Day cycles are overlapping. One day ends at ' + minutes_to_string(day_cycle.night_start) + ' and other starts at ' + minutes_to_string(other_day_cycle.day_start) + '. ' + generic_message)
          return
        end
        if minutes_diff(day_cycle.night_start, other_day_cycle.night_start) < 4
          errors.add(:day_cycles, 'Day cycles are overlapping. One day ends at ' + minutes_to_string(day_cycle.night_start) + ' and other ends at ' + minutes_to_string(other_day_cycle.night_start) + '. ' + generic_message)
          return
        end
      end
    end
  end


  def minutes_diff(minutes1, minutes2)
    if minutes1 < 0 || minutes1 >= 24*60
      raise ArgumentError, 'First argument is not within valid range. Value: ' + minutes1.to_s()
    end
    if minutes2 < 0 || minutes2 >= 24*60
      raise ArgumentError, 'Second argument is not within valid range. Value: ' + minutes2.to_s()
    end

    bigger = minutes1 > minutes2 ? minutes1 : minutes2
    smaller = minutes1 == bigger ? minutes2 : minutes1

    diff1 = bigger - smaller
    diff2 = smaller + (24*60) - bigger

    [diff1, diff2].min()
  end

  def minutes_to_string(minutes)
    (minutes / 60).to_s().rjust(2, '0') + ':' + (minutes % 60).to_s().rjust(2, '0')
  end

end