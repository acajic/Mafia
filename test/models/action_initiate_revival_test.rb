require 'test_helper'

class ActionInitiateRevivalTest < ActiveSupport::TestCase

  def test_initiate_revival_successful
    city = create(:city)

    city.start()

    necromancer_resident = city.residents.where(:role_id => Role::NECROMANCER).where(:alive => true).first()

    filtered_action_results = ActionResult.query_action_results(city.id, necromancer_resident.user_id, Role::NECROMANCER, nil, nil, nil) # this will create MAFIA_MEMBERS result


    non_necromancer_residents = city.residents.where('role_id != ?', Role::NECROMANCER).sample(3)
    non_necromancer_residents.each { |some_resident|
      some_resident.alive = false
      some_resident.save()
    }
    target_resident = non_necromancer_residents.sample()

    initiate_revival_action = Action.create(:resident => necromancer_resident, :role => necromancer_resident.role, :action_type_id => ActionType::INITIATE_REVIVAL, :input => { ActionType::Revive::KEY_TARGET_ID => target_resident.id })

    action_type_params_per_resident_role_action_type = city.action_type_params_per_resident_role_action_type()
    action_valid = initiate_revival_action.action_valid?(action_type_params_per_resident_role_action_type)
    assert(action_valid, 'Inititate revival should be valid')

  end

  def test_initiate_revival_unsuccessful
    city = create(:city)

    city.start()

    necromancer_resident = city.residents.where(:role_id => Role::NECROMANCER).where(:alive => true).first()

    filtered_action_results = ActionResult.query_action_results(city.id, necromancer_resident.user_id, Role::NECROMANCER, nil, nil, nil)




    mafia_members_action_result = city.action_results.where(:action_result_type_id => ActionResultType::MAFIA_MEMBERS, :resident_id => necromancer_resident.id).order('action_results.id DESC').first()
    result_mafia_members = mafia_members_action_result.result.dup()
    mafia_members_ids = result_mafia_members[ActionResultType::SingleRequired::MafiaMembers::KEY_MAFIA_MEMBERS]
    mafia_members_ids.delete(necromancer_resident.id)
    random_innocent_resident = city.residents.joins('LEFT JOIN roles ON residents.role_id = roles.id').where('roles.affiliation_id = ?', Affiliation::CITIZENS).sample()
    mafia_members_ids << random_innocent_resident.id

    ActionResult.create(:action_result_type_id => ActionResultType::MAFIA_MEMBERS, :resident => necromancer_resident, :city => city, :day => city.current_day(true), :role_id => Role::NECROMANCER, :is_automatically_generated => false, :result => result_mafia_members)

    non_necromancer_residents = city.residents.where('role_id != ?', Role::NECROMANCER).sample(3)
    non_necromancer_residents.each { |some_resident|
      some_resident.alive = false
      some_resident.save()
    }
    target_resident = non_necromancer_residents.sample()

    initiate_revival_action = Action.create(:resident => necromancer_resident, :role => necromancer_resident.role, :action_type_id => ActionType::INITIATE_REVIVAL, :input => { ActionType::Revive::KEY_TARGET_ID => target_resident.id })

    action_type_params_per_resident_role_action_type = city.action_type_params_per_resident_role_action_type()
    action_valid = initiate_revival_action.action_valid?(action_type_params_per_resident_role_action_type)
    assert(!action_valid, 'Inititate revival should not be valid')

  end

end