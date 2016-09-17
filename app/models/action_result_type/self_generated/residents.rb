class ActionResultType::SelfGenerated::Residents < ActionResultType::SelfGenerated

  KEY_RESIDENTS = 'residents'
  KEY_RESIDENT_ID = 'id'
  KEY_RESIDENT_ALIVE = 'alive'

  def before_creating
    self.name = 'Residents'
    self.is_self_generated = true
    self.trigger_id = Trigger::BOTH
    self.description = 'Residents know at all times which players are alive and which of them are dead.'
  end


  def self.self_generated_results(city, day, trigger_id)
    self_generated_residents = city.residents(true).map { |resident|
      self.resident_status_hash(resident)
    }

    # generate only one SelfGenerated::Residents result, with resident_id == nil
    # additional SelfGenerated::Residents results (that are aimed to be presented only to selected users) can be created in resolvers if necessary
    self_generated_results = [self.self_generated_result_hash(city.id, self_generated_residents)]

    self_generated_results
  end

  def self.self_generated_result_hash(city_id, self_generated_residents)
    {:action => nil,
     :action_result_type_id => ActionResultType::RESIDENTS,
     :city_id => city_id,
     :resident_id => nil,
     :role_id => nil,
     :result => {KEY_RESIDENTS => self_generated_residents},
     :is_automatically_generated => true}
  end


  # @param [Resident] resident
  def self.resident_status_hash(resident)
    {KEY_RESIDENT_ID => resident.id, KEY_RESIDENT_ALIVE => resident.alive}
  end

  def self.set_self_generated_resident_alive(self_generated_results_array, resident_id, alive)
    self_generated_results_array.map! { |self_generated_residents_result|
      self_generated_residents = self_generated_residents_result[:result][ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS]
      self_generated_residents.map! { |some_resident_hash|
        if some_resident_hash[KEY_RESIDENT_ID] == resident_id
          some_resident_hash[KEY_RESIDENT_ALIVE] = alive
        end
        some_resident_hash
      }

      self_generated_residents_result
    }
  end

  def self.set_self_generated_residents_alive(self_generated_results_array, resident_id_status_hash)
    self_generated_results_array.map! { |self_generated_result_residents|
      self_generated_residents = self_generated_result_residents[:result][ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS]
      self_generated_residents.map! { |some_resident_hash|
        if resident_id_status_hash.has_key?(some_resident_hash[KEY_RESIDENT_ID])
          some_resident_hash[KEY_RESIDENT_ALIVE] = resident_id_status_hash[some_resident_hash[KEY_RESIDENT_ID]]
        end
      }

      self_generated_result_residents
    }
  end


end