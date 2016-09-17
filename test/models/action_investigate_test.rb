require 'test_helper'

class ActionInvestigateTest < ActiveSupport::TestCase

  def test_investigate_successful

    city = create(:city)
    detective_resident = city.residents.where(:role_id => Role::DETECTIVE, :alive => true).first

    target_mafia_resident = city.residents.includes(:role).where('roles.affiliation_id' => Affiliation::MAFIA).sample

    Action.create(:resident_id => detective_resident.id, :role_id => detective_resident.role_id, :action_type_id => ActionType::INVESTIGATE, :input => {ActionType::Investigate::KEY_TARGET_ID => target_mafia_resident.id})

    Day.create(:city_id => city.id, :number => 0)
    city.handle_day_start()

    action_result_investigate = city.action_results.where(:action_result_type_id => ActionResultType::INVESTIGATE).last

    is_correct_target_id = action_result_investigate.result[ActionResultType::Investigate::KEY_TARGET_ID] == target_mafia_resident.id
    is_investigate_successful = action_result_investigate.result[ActionResultType::Investigate::KEY_SUCCESS]

    assert is_correct_target_id && is_investigate_successful


  end


  def test_investigate_unsuccessful

    city = create(:city)
    detective_resident = city.residents.where(:role_id => Role::DETECTIVE, :alive => true).first

    target_non_mafia_resident = city.residents.includes(:role).select { |some_resident|
      some_resident.role.affiliation_id != Affiliation::MAFIA
    }.sample




    Action.create(:resident_id => detective_resident.id, :role_id => detective_resident.role_id, :action_type_id => ActionType::INVESTIGATE, :input => {ActionType::Investigate::KEY_TARGET_ID => target_non_mafia_resident.id})

    Day.create(:city_id => city.id, :number => 0)
    city.handle_day_start()

    action_result_investigate = city.action_results.where(:action_result_type_id => ActionResultType::INVESTIGATE).last

    is_correct_target_id = action_result_investigate.result[ActionResultType::Investigate::KEY_TARGET_ID] == target_non_mafia_resident.id
    is_investigate_unsuccessful = !action_result_investigate.result[ActionResultType::Investigate::KEY_SUCCESS]

    assert is_correct_target_id && is_investigate_unsuccessful


  end

end