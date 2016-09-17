module Module::Action::Initializer

  def init_hash(params)

    cleaned_params = Module::ParameterPruning.prune_parameters_for_model(params, Action.new())

    cleaned_params.delete(:id)
    cleaned_params.delete(:is_processed)
    cleaned_params.delete(:resident_alive)

    cleaned_params
  end

end