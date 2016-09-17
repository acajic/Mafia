require 'test_helper'

class ActionReviveTest < ActiveSupport::TestCase

  def test_revive_successful
    city = create(:city)

    city.start()

    necromancer_resident = city.residents.where(:role_id => Role::NECROMANCER).where(:alive => true).first()


    filtered_action_results = ActionResult.query_action_results(city.id, necromancer_resident.user_id, Role::NECROMANCER, nil, nil, nil)



    rratp = ResidentRoleActionTypeParamsModel.where(:resident_id => necromancer_resident.id, :role_id => necromancer_resident.role_id, :action_type_id => ActionType::REVIVE).first()
    if rratp.nil?
      rratp = ResidentRoleActionTypeParamsModel.create(:resident => necromancer_resident, :role => necromancer_resident.role, :action_type_id => ActionType::REVIVE, :action_type_params_hash => {
          ActionType::Revive::PARAM_DAYS_UNTIL_REVEAL => 1,
          ActionType::Revive::PARAM_LIFETIME_ACTIONS_COUNT => 1
      })
    end

    non_mafia_residents = city.residents.joins('LEFT JOIN roles ON residents.role_id = roles.id').where('roles.affiliation_id != ?', Affiliation::MAFIA).sample(3)
    non_mafia_residents.each { |some_resident|
      some_resident.alive = false
      some_resident.save()
    }


    target_resident = non_mafia_residents.sample()
    Action.create(:resident => necromancer_resident, :role => necromancer_resident.role, :action_type_id => ActionType::MAFIA_MEMBERS, :input => { })

    Action.create(:resident => necromancer_resident, :role => necromancer_resident.role, :action_type_id => ActionType::REVIVE, :input => { ActionType::Revive::KEY_TARGET_ID => target_resident.id })
    city.handle_day_start()

    city.action_results.reload()

    residents_action_result = city.action_results.where(:action_result_type_id => ActionResultType::RESIDENTS, :resident_id => nil).order('action_results.id DESC').first()
    resident_statuses = residents_action_result.result[ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS]

    target_resident_status = resident_statuses.select {|resident_status| resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == target_resident.id}.first()
    assert(!target_resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE], 'Zombie should appear dead for one day')

    revive_occurred_action_results = city.action_results.where(:action_result_type_id => ActionResultType::REVIVAL_OCCURRED)

    target_resident.reload()

    assert(revive_occurred_action_results.count == 1, 'Revive occurred action result should be created.')
    assert(target_resident.alive, 'Resident should be successfully revived')
    assert(target_resident.role_id == Role::ZOMBIE, "Resident's new role should be Zombie")
    assert(target_resident.saved_role_id == Role::ZOMBIE, "Resident's new saved role should be Zombie")

    mafia_members_result = necromancer_resident.action_results.where(:action_result_type_id => ActionResultType::MAFIA_MEMBERS).order('action_results.id DESC').first()
    mafia_members_ids = mafia_members_result.result[ActionResultType::SingleRequired::MafiaMembers::KEY_MAFIA_MEMBERS]
    assert(!mafia_members_ids.include?(target_resident.id), 'Zombie should not yet be included in mafia members result')

    city.handle_night_start()

    city.action_results.reload()

    residents_action_result = city.action_results.where(:action_result_type_id => ActionResultType::RESIDENTS, :resident_id => nil).order('action_results.id DESC').first()
    resident_statuses = residents_action_result.result[ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS]

    target_resident_status = resident_statuses.select {|resident_status| resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == target_resident.id}.first()
    assert(!target_resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE], 'Zombie should appear dead for one day')

    city.handle_day_start()

    city.action_results.reload()

    residents_action_result = city.action_results.where(:action_result_type_id => ActionResultType::RESIDENTS, :resident_id => nil).order('action_results.id DESC').first()
    resident_statuses = residents_action_result.result[ActionResultType::SelfGenerated::Residents::KEY_RESIDENTS]

    target_resident_status = resident_statuses.select {|resident_status| resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ID] == target_resident.id}.first()
    assert(target_resident_status[ActionResultType::SelfGenerated::Residents::KEY_RESIDENT_ALIVE], 'It should be revealed that user has been revived')

    revival_revealed_action_result = city.action_results.where(:action_result_type_id => ActionResultType::REVIVAL_REVEALED, :resident_id => nil).first()
    assert(revival_revealed_action_result.result[ActionResultType::RevivalRevealed::KEY_TARGET_ID] == target_resident.id, 'It should be announced which resident was revived.')


    mafia_members_result = necromancer_resident.action_results.where(:action_result_type_id => ActionResultType::MAFIA_MEMBERS).order('action_results.id DESC').first()
    mafia_members_ids = mafia_members_result.result[ActionResultType::SingleRequired::MafiaMembers::KEY_MAFIA_MEMBERS]
    assert(mafia_members_ids.include?(target_resident.id), 'Zombie should be included in mafia members result')

  end


end