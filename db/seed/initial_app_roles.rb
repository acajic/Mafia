# Initial App Roles

InitialAppRole.find_or_create_by(:description => 'All emails', :email_pattern => '.*', :app_role_id => AppRole::GAME_CREATOR)
InitialAppRole.find_or_create_by(:description => 'Only @fer.hr emails can register', :email_pattern => '@fer.hr$')
InitialAppRole.find_or_create_by(:description => 'Temporary initial app role for creating users during seed.', :email_pattern => '@email.com$')
