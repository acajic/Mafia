require 'test_helper'

class ActionSheriffIdentitiesTest < ActiveSupport::TestCase

  def test_sheriff_identities_successful
    city = create(:city)

    sheriff_resident = city.residents.where(:role_id => Role::SHERIFF).where(:alive => true).first
    non_sheriff_residents = city.residents.where("role_id != ?", Role::SHERIFF).sample(3)
    non_sheriff_residents.each { |some_resident|
      some_resident.alive = false
      some_resident.save()
    }

    Action.create(:resident => sheriff_resident, :role => sheriff_resident.role, :action_type_id => ActionType::SHERIFF_IDENTITIES)

    Day.create(:city_id => city.id, :number => 0)

    city.handle_day_start()

    action_result = city.action_results.where(:action_result_type_id => ActionResultType::SHERIFF_IDENTITIES).last

    dead_resident_roles = action_result.result[ActionResultType::SheriffIdentities::KEY_DEAD_RESIDENTS_ROLES]
    correct_residents = true
    correct_roles = true
    dead_resident_roles.each { |dead_resident_role_hash|
      matching_resident = non_sheriff_residents.select { |resident| resident.id == dead_resident_role_hash[ActionResultType::SheriffIdentities::KEY_RESIDENT_ID]}
      if matching_resident
        #
      else
        correct_residents = false
      end

      if matching_resident.role_id == dead_resident_role_hash[ActionResultType::SheriffIdentities::KEY_RESIDENT_ROLE_ID]
        #
      else
        correct_roles = false
      end
    }

    resident_role_action_type_params = ResidentRoleActionTypeParamsModel.where(:resident => sheriff_resident, :role => sheriff_resident.role, :action_type_id => ActionType::SHERIFF_IDENTITIES).first
    original_actions_count = resident_role_action_type_params.original_action_type_params_hash[ActionType::SheriffIdentities::PARAM_LIFETIME_ACTIONS_COUNT]
    new_actions_count = resident_role_action_type_params.action_type_params_hash[ActionType::SheriffIdentities::PARAM_LIFETIME_ACTIONS_COUNT]

    are_action_type_params_updated = (original_actions_count == -1 && new_actions_count == -1) || (original_actions_count -1 == new_actions_count)


    action_type_params_result = city.action_results.where(:action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS, :resident => sheriff_resident).last
    result_actions_count = action_type_params_result.result[ActionResultType::SelfGenerated::ActionTypeParams::KEY_ACTION_TYPES_PARAMS][sheriff_resident.role_id.to_s()][ActionType::SHERIFF_IDENTITIES.to_s()][ActionType::SheriffIdentities::PARAM_LIFETIME_ACTIONS_COUNT]
    does_result_match_actual_state = result_actions_count == new_actions_count


    assert(correct_residents, 'Sheriff identities gives info on incorrect residents.')
    assert(correct_roles, 'Sheriff identities gives incorrect info on deceased residents.')
    assert(are_action_type_params_updated, 'Action type params are not updated.')
    assert(does_result_match_actual_state, 'Action type params in result do not match actual state of action type params.')
  end


end