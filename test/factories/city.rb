FactoryGirl.define do
  factory :city do
    sequence(:name) { |n| "city#{n}" }


    before :create do |city|

      # city has roles

      role_quantities = {
        Role::CITIZEN => 10,
        Role::DOCTOR => 1,
        Role::DETECTIVE => 1,
        Role::MOB => 4,
        Role::SHERIFF => 1,
        Role::TELLER => 1,
        Role::TERRORIST => 1,
        Role::JOURNALIST => 1,
        Role::FUGITIVE => 1,
        Role::DEPUTY => 1,
        Role::ELDER => 2,
        Role::NECROMANCER => 1,
        Role::FORGER => 2,
      }


      role_quantities.each_pair { |key, value|
        role = Role.find(key)
        value.times {
          city_has_role = create(:city_has_role, :role => role)
          city.city_has_roles << city_has_role

          resident = create(:resident, :role => role)
          if city.user_creator.nil?
            city.user_creator = resident.user
          end
          city.residents << resident
        }
      }

      # day cycles

      day_cycle = create(:day_cycle, :day_start => 9*60, :night_start => 12*60)
      city.day_cycles << day_cycle
      day_cycle = create(:day_cycle, :day_start => 15*60, :night_start => 18*60)
      city.day_cycles << day_cycle


      # city has game end conditions

      create(:city_has_game_end_condition, :city => city, :game_end_condition_id => GameEndCondition::CITIZENS_VS_MAfIA)

      # city has self generated types
      create(:city_has_self_generated_result_type, :city => city, :action_result_type_id => ActionResultType::RESIDENTS)
      create(:city_has_self_generated_result_type, :city => city, :action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS)



    end

  end

end