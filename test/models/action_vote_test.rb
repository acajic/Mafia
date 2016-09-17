require 'test_helper'

class ActionVoteTest < ActiveSupport::TestCase

  def test_vote
    city = create(:city)

    first_resident = city.residents.first
    target_resident = city.residents.all[1]

    action_type_vote = ActionType.find(ActionType::VOTE)

    action = Action.create(:resident => first_resident, :role => first_resident.role, :action_type => action_type_vote, :input => {ActionType::Vote::KEY_TARGET_ID => target_resident.id})

    Day.create(:city_id => city.id, :number => 0)

    city.handle_night_start()

    action_results = city.action_results.where(:action_result_type_id => ActionResultType::VOTE)

    action_results = action_results.select { |action_result|
      action_result.resident_id.nil?
    }
    action_result = action_results[0]

    is_correct_target_id = action_result.result[ActionResultType::Vote::KEY_TARGET_ID] == target_resident.id

    target_resident.reload
    is_target_resident_dead = !target_resident.alive


    self_generated_residents_result = city.action_results.where(:action_result_type_id => ActionResultType::RESIDENTS).last
    resident_alive_status_hash = self_generated_residents_result.result[ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS].select { |r|
      r[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == target_resident.id
    }[0]
    is_target_resident_dead_in_residents_result = !resident_alive_status_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE]


    assert(is_correct_target_id, 'Vote target is not what is should be.')
    assert(is_target_resident_dead, 'Vote target should be dead, but is alive.')
    assert(is_target_resident_dead_in_residents_result, 'Self generated result - Resident, should report that target resident is dead, but it does not.')

    action.reload()
    assert(!action.nil?, 'Action dissapeared.')

  end

end