require 'test_helper'

class ActionTerroristBombTest < ActiveSupport::TestCase

  def test_terrorist_bomb
    city = create(:city)

    city.start()


    terrorist_resident = city.residents.where(:role_id => Role::TERRORIST).first

    filtered_action_results = ActionResult.query_action_results(city.id, terrorist_resident.user_id, Role::TERRORIST, nil, nil, nil) # this will create MAFIA_MEMBERS result



    target_resident = city.residents.where("role_id != ?", Role::TERRORIST)[0]

    action_type_terrorist_bomb = ActionType.find(ActionType::TERRORIST_BOMB)

    Day.create(:city_id => city.id, :number => 0)
    action = Action.create(:resident => terrorist_resident, :role => terrorist_resident.role, :action_type => action_type_terrorist_bomb, :input => {ActionType::TerroristBomb::KEY_TARGET_ID => target_resident.id})

    scheduler = AppConfig.instance.scheduler
    jobs = scheduler.jobs(:tag => action.scheduler_tag)
    assert(jobs.count == 1, 'Terrorist bombing should be scheduled but is not.')


    action_type_terrorist_bomb.detonate_action(action)


    action_result = city.action_results.where(:action_result_type_id => ActionResultType::TERRORIST_BOMB).last

    target_ids_contain_terrorist = action_result.result[ActionResultType::TerroristBomb::KEY_TARGET_IDS].include?(terrorist_resident.id)
    target_ids_contain_target = action_result.result[ActionResultType::TerroristBomb::KEY_TARGET_IDS].include?(target_resident.id)
    assert(target_ids_contain_terrorist, 'Target ids should include terrorist.')
    assert(target_ids_contain_target, 'Target ids should include the target.')


    terrorist_resident.reload()
    target_resident.reload()
    is_target_resident_dead = !target_resident.alive
    is_terrorist_dead = !terrorist_resident.alive
    assert(is_target_resident_dead, 'Target resident should be dead, but he is not.')
    assert(is_terrorist_dead, 'Terrorist should be dead, but he is not.')


    self_generated_residents_result = city.action_results.where(:action_result_type_id => ActionResultType::RESIDENTS).last
    resident_alive_status_hash = self_generated_residents_result.result[ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS].select { |r|
      r[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == target_resident.id
    }[0]
    is_target_resident_dead_in_residents_result = !resident_alive_status_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE]

    assert(is_target_resident_dead_in_residents_result, 'Self generated result - Resident, should report that target resident is dead, but it does not.')


    resident_alive_status_hash = self_generated_residents_result.result[ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS].select { |r|
      r[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == terrorist_resident.id
    }[0]
    is_terrorist_dead_in_residents_result = !resident_alive_status_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE]
    assert(is_terrorist_dead_in_residents_result, 'Self generated result - Resident, should report that terrorist is dead, but it does not.')


  end

end