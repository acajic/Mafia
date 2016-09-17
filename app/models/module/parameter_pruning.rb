module Module::ParameterPruning

  def self.prune_parameters_for_model(params, model_instance)

    pruned_params = params.dup

    params.each { |key, value|
      if model_instance.respond_to?(key)
      else
        pruned_params.delete(key)
      end
    }

    return pruned_params
  end

end