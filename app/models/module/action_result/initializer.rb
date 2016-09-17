module Module::ActionResult::Initializer

  def init_hash(params)

    cleaned_params = params.permit(:city_id, :role_id, :resident_id, :day_id, :result, :action_id) # Module::ParameterPruning.prune_parameters_for_model(params, ActionResult.new())

    action_result_type_id = params.require(:action_result_type).require(:id)
    cleaned_params[:action_result_type_id] = action_result_type_id
    cleaned_params[:result] = params[:result]

    cleaned_params
  end


end