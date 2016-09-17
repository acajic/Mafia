require 'test_helper'

class ActionVoteMafiaTest < ActiveSupport::TestCase

  def test_vote_mafia_successful
    city = create(:city)

    mafiaMembers = city.residents.includes(:role).where("roles.affiliation_id" => Affiliation::MAFIA).where(:alive => true)
    votingMafiaMembers = mafiaMembers.sample(mafiaMembers.count / 2 + 1)

    target_innocent_resident = city.residents.includes(:role).where(:alive => true).where("roles.affiliation_id" => Affiliation::CITIZENS).sample

    action_type_vote_mafia = ActionType.find(ActionType::VOTE_MAFIA)

    actions = []
    action = nil
    votingMafiaMembers.each { |mafia_resident|
      action = Action.create(:resident => mafia_resident, :role => mafia_resident.role, :action_type => action_type_vote_mafia, :input => {ActionType::VoteMafia::KEY_TARGET_ID => target_innocent_resident.id})

    }

    Day.create(:city_id => city.id, :number => 0)

    city.handle_day_start()

    action_result = city.action_results.where(:action_result_type_id => ActionResultType::VOTE_MAFIA).last

    is_correct_target_id = action_result.result[ActionResultType::VoteMafia::KEY_TARGET_ID] == target_innocent_resident.id

    target_innocent_resident.reload
    is_target_resident_dead = !target_innocent_resident.alive

    assert(is_correct_target_id, 'Target is incorrect')
    assert(is_target_resident_dead, 'Target is not dead. It should be.')

    action.reload()
    assert(!action.nil?, 'Action dissapeared.')
  end

  def test_vote_mafia_insufficient_votes

    city = create(:city)

    mafiaMembers = city.residents.includes(:role).where("roles.affiliation_id" => Affiliation::MAFIA).where(:alive => true)
    votingMafiaMembers = mafiaMembers.sample(mafiaMembers.count / 2)

    target_innocent_resident = city.residents.includes(:role).where(:alive => true).where("roles.affiliation_id" => Affiliation::CITIZENS).sample

    action_type_vote_mafia = ActionType.find(ActionType::VOTE_MAFIA)

    actions = []
    votingMafiaMembers.each { |mafia_resident|
      action = Action.create(:resident => mafia_resident, :role => mafia_resident.role, :action_type => action_type_vote_mafia, :input => {ActionType::VoteMafia::KEY_TARGET_ID => target_innocent_resident.id})
      actions << action
    }

    Day.create(:city_id => city.id, :number => 0)

    city.handle_day_start()

    action_results = city.action_results.where(:action_result_type_id => ActionResultType::VOTE_MAFIA).to_a

    public_action_results = action_results.select { |action_result|
      action_result[:resident_id].nil?
    }

    action_result = public_action_results[0]

    public_result_hides_target_id = action_result.result[ActionResultType::VoteMafia::KEY_TARGET_ID] != target_innocent_resident.id


    target_innocent_resident.reload
    is_target_resident_alive = target_innocent_resident.alive

    assert is_target_resident_alive && public_result_hides_target_id
  end


end