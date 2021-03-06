require 'test_helper'

class ActionElderVoteTest < ActiveSupport::TestCase

  def test_elder_vote
    city = create(:city)

    elder_residents = city.residents.where(:role_id => Role::ELDER, :alive => true).to_a()
    target_residents = city.residents.sample(5)

    action_type_elder_vote = ActionType.find(ActionType::ELDER_VOTE)

    Action.create(:resident => elder_residents[0], :role_id => elder_residents[0].role_id, :action_type => action_type_elder_vote, :input => {ActionType::ElderVote::KEY_TARGET_ID => target_residents[0].id})
    Action.create(:resident => elder_residents[0], :role_id => elder_residents[0].role_id, :action_type => action_type_elder_vote, :input => {ActionType::ElderVote::KEY_TARGET_ID => target_residents[1].id})
    Action.create(:resident => elder_residents[0], :role_id => elder_residents[0].role_id, :action_type => action_type_elder_vote, :input => {ActionType::ElderVote::KEY_TARGET_ID => target_residents[2].id})
    Action.create(:resident => elder_residents[1], :role_id => elder_residents[1].role_id, :action_type => action_type_elder_vote, :input => {ActionType::ElderVote::KEY_TARGET_ID => target_residents[2].id})
    Action.create(:resident => elder_residents[1], :role_id => elder_residents[1].role_id, :action_type => action_type_elder_vote, :input => {ActionType::ElderVote::KEY_TARGET_ID => target_residents[3].id})
    Action.create(:resident => elder_residents[1], :role_id => elder_residents[1].role_id, :action_type => action_type_elder_vote, :input => {ActionType::ElderVote::KEY_TARGET_ID => target_residents[4].id})


    Day.create(:city_id => city.id, :number => 0)

    city.handle_night_start()

    action_results = city.action_results.where(:action_result_type_id => ActionResultType::VOTE)

    action_results = action_results.select { |action_result|
      action_result.resident_id.nil?
    }
    action_result = action_results[0]

    is_correct_target_id = action_result.result[ActionResultType::Vote::KEY_TARGET_ID] == target_residents[2].id

    target_residents[2].reload
    is_target_resident_dead = !target_residents[2].alive


    self_generated_residents_result = city.action_results.where(:action_result_type_id => ActionResultType::RESIDENTS).last
    resident_alive_status_hash = self_generated_residents_result.result[ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS].select { |r|
      r[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == target_residents[2].id
    }[0]
    is_target_resident_dead_in_residents_result = !resident_alive_status_hash[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE]


    assert(is_correct_target_id, 'Union of many ElderVote actions performed by two users is incorrect.')
    assert(is_target_resident_dead, 'Elder vote target should be dead, but is alive.')
    assert(is_target_resident_dead_in_residents_result, 'Self generated result - Resident, should report that target resident is dead, but it does not.')


  end

end