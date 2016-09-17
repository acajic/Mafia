require 'test_helper'

class ActionProtectTest < ActiveSupport::TestCase

  def test_protect_successful
    city = create(:city)

    mafia_members = city.residents.includes(:role).where('roles.affiliation_id' => Affiliation::MAFIA).where(:alive => true)
    voting_mafia_members = mafia_members.sample(mafia_members.count / 2 + 1)

    doctor_resident = city.residents.where(:role_id => Role::DOCTOR, :alive => true).first


    target_innocent_resident = city.residents.includes(:role).where(:alive => true).where('roles.affiliation_id' => Affiliation::CITIZENS).where('residents.id <> ?', doctor_resident.id).sample

    voting_mafia_members.each { |mafia_resident|
      Action.create(:resident => mafia_resident, :role => mafia_resident.role, :action_type_id => ActionType::VOTE_MAFIA, :input => {ActionType::VoteMafia::KEY_TARGET_ID => target_innocent_resident.id})
    }

    Action.create(:resident => doctor_resident, :role => doctor_resident.role, :action_type_id => ActionType::PROTECT, :input => {ActionType::Protect::KEY_TARGET_ID => target_innocent_resident.id})

    Day.create(:city_id => city.id, :number => 0)

    city.handle_day_start()

    action_result = city.action_results.where(:action_result_type_id => ActionResultType::VOTE_MAFIA).last

    is_target_id_hidden = action_result.result[ActionResultType::VoteMafia::KEY_TARGET_ID] != target_innocent_resident.id

    target_innocent_resident.reload
    is_target_resident_alive = target_innocent_resident.alive

    protect_action_result = city.action_results.where(:action_result_type_id => ActionResultType::PROTECT, :resident_id => doctor_resident.id).last
    is_protect_successful = protect_action_result.result[ActionResultType::Protect::KEY_SUCCESS]

    assert is_target_id_hidden && is_target_resident_alive && is_protect_successful
  end

  def test_protect_unsuccessful
    city = create(:city)

    mafia_members = city.residents.includes(:role).where("roles.affiliation_id" => Affiliation::MAFIA).where(:alive => true)
    voting_mafia_members = mafia_members.sample(mafia_members.count / 2 + 1)

    doctor_resident = city.residents.where(:role_id => Role::DOCTOR, :alive => true).first


    target_innocent_resident = city.residents.includes(:role).where(:alive => true).where("roles.affiliation_id" => Affiliation::CITIZENS).where("role_id != ?", Role::DOCTOR).sample
    target_other_resident = city.residents.includes(:role).where(:alive => true).where("id != ?", target_innocent_resident.id).sample


    voting_mafia_members.each { |mafia_resident|
      Action.create(:resident => mafia_resident, :role => mafia_resident.role, :action_type_id => ActionType::VOTE_MAFIA, :input => {ActionType::VoteMafia::KEY_TARGET_ID => target_innocent_resident.id})
    }

    Action.create(:resident => doctor_resident, :role => doctor_resident.role, :action_type_id => ActionType::PROTECT, :input => {ActionType::Protect::KEY_TARGET_ID => target_other_resident.id})

    Day.create(:city_id => city.id, :number => 0)

    city.handle_day_start()

    action_result = city.action_results.where(:action_result_type_id => ActionResultType::VOTE_MAFIA).last

    target_innocent_resident.reload
    is_target_resident_dead = !target_innocent_resident.alive

    protect_action_result = city.action_results.where(:action_result_type_id => ActionResultType::PROTECT, :resident_id => doctor_resident.id).last
    is_protect_unsuccessful = !protect_action_result.result[ActionResultType::Protect::KEY_SUCCESS]
    is_protect_target_unchanged = protect_action_result.result[ActionResultType::Protect::KEY_TARGET_ID] == target_other_resident.id

    assert(is_target_resident_dead, 'Target resident is not dead, although it should be.')
    assert(is_protect_unsuccessful, 'Protect action is successful, although it shouldn\'t be.')
    assert(is_protect_target_unchanged, 'Protect target id is not the same as VoteMafia target id.')
  end

end