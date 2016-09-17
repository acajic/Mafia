Mafia::Application.routes.draw do
  apipie

  match '*path', :controller => 'application', :action => 'handle_options_request', :via => [:options] #:constraints => {:method => 'OPTIONS'}

  resources :users do
    collection do
      get 'me'
      get 'confirm_email'
      get 'allowed_email_patterns'
      post 'forgot_password'
      get 'confirm_forgot_password'
    end
    member do
      get 'resend_confirmation_email'
    end
  end



  get 'user_preference/me', :to => 'user_preference#update_my_user_preference'
  post 'user_preference/unsubscribe', :to => 'user_preference#unsubscribe'



  resources :cities do
    member do
      post 'invite'
      post 'start'
      post 'stop'
      post 'pause'
      post 'resume'
      delete 'invitation/:user_id', :to => 'cities#cancel_invitation'
      delete 'join_request/:user_id', :to => 'cities#reject_join_request'
      delete 'join_request', :to => 'cities#cancel_join_request'
      delete 'user/:user_id', :to => 'cities#kick_user'
      post 'join'
      post 'leave'

      post 'trigger_day_start'
      post 'trigger_night_start'

      post 'accept_invitation'
      post 'join_request/:user_id', :to => 'cities#accept_join_request'


    end
    collection do
      get 'ping'
      get 'search/:search', :to => 'cities#all_cities_for_search_text'
      get 'me/search/:search', :to => 'cities#my_cities_for_search_text'
      get 'me'
    end
  end



  resources :residents do
    collection do
      #get 'me'
      post 'save_role'
    end
  end

  resources :actions do
    collection do
      delete 'cancel_unprocessed_actions'
    end
  end



  resources :action_results

  get 'action_results/city/:city_id/role/:role_id', :to => 'action_results#action_results_for_city_and_role'


  resources :action_result_types
  resources :roles
  resources :game_end_conditions
  resources :self_generated_result_types
  resources :action_type
  resources :days
  resources :app_roles
  resources :initial_app_roles
  resources :granted_app_roles

  resources :role_picks do
    collection do
      get 'me'
      post 'me', :to => 'role_picks#create_my_role_pick'
    end
  end

  namespace :payments do
    resources :payments
    resources :payment_types
  end

  namespace :purchases do
    resources :game_purchases, :role_pick_purchases, :subscription_purchases
  end


  get 'impersonate_login/:user_id', :to => 'auth_tokens#create_auth_token_for_user'

  post 'login', :to => 'auth_tokens#create'
  delete 'logout', :to => 'auth_tokens#invalidate_auth_token'

  post 'exchange_email_confirmation_code', :to=> 'auth_tokens#exchange_email_confirmation_code'

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'cities#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # get ':controller(/:action(/:id))(.:format)'


end
