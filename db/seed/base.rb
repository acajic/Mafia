


# affiliations

Affiliation::Citizens.create() unless Affiliation::Citizens.exists?
Affiliation::MafiaAffiliation.create() unless Affiliation::MafiaAffiliation.exists?


# roles

Role::Citizen.create() unless Role::Citizen.exists?
Role::Doctor.create() unless Role::Doctor.exists?
Role::Detective.create() unless Role::Detective.exists?
Role::Mob.create() unless Role::Mob.exists?
Role::Sheriff.create() unless Role::Sheriff.exists?
Role::Teller.create() unless Role::Teller.exists?
Role::Terrorist.create() unless Role::Terrorist.exists?
Role::Journalist.create() unless Role::Journalist.exists?
Role::Fugitive.create() unless Role::Fugitive.exists?
Role::Deputy.create() unless Role::Deputy.exists?
Role::Elder.create() unless Role::Elder.exists?
if Role::Necromancer.exists?
  if Role::Zombie.exists?
  else
    role_zombie = Role::Zombie.create()
    role_necromancer.implicated_roles = [role_zombie]
    role_necromancer.save()
  end
else

  role_necromancer = Role::Necromancer.create()
  if Role::Zombie.exists?
    role_zombie = Role.find(Role::ZOMBIE)
  else
    role_zombie = Role::Zombie.create()
  end
  role_necromancer.implicated_roles = [role_zombie]
  role_necromancer.save()
end

Role::Forger.create() unless Role::Forger.exists?



# action types

ActionType::Vote.create() unless ActionType::Vote.exists?
ActionType::Protect.create() unless ActionType::Protect.exists?
ActionType::Investigate.create() unless ActionType::Investigate.exists?
ActionType::VoteMafia.create() unless ActionType::VoteMafia.exists?
ActionType::SheriffIdentities.create() unless ActionType::SheriffIdentities.exists?
ActionType::TellerVotes.create() unless ActionType::TellerVotes.exists?
ActionType::TerroristBomb.create() unless ActionType::TerroristBomb.exists?
ActionType::SingleRequired::MafiaMembers.create() unless ActionType::SingleRequired::MafiaMembers.exists?
ActionType::SingleRequired::Residents.create() unless ActionType::SingleRequired::Residents.exists?

ActionType::JournalistInvestigate.create() unless ActionType::JournalistInvestigate.exists?
ActionType::DeputyIdentities.create() unless ActionType::DeputyIdentities.exists?
ActionType::ElderVote.create() unless ActionType::ElderVote.exists?

ActionType::InitiateRevival.create() unless ActionType::InitiateRevival.exists?
ActionType::Revive.create() unless ActionType::Revive.exists?

ActionType::ForgerVote.create() unless ActionType::ForgerVote.exists?


# action results types

ActionResultType::Vote.create() unless ActionResultType::Vote.exists?
ActionResultType::Protect.create() unless ActionResultType::Protect.exists?
ActionResultType::Investigate.create() unless ActionResultType::Investigate.exists?
ActionResultType::VoteMafia.create() unless ActionResultType::VoteMafia.exists?
ActionResultType::SheriffIdentities.create() unless ActionResultType::SheriffIdentities.exists?
ActionResultType::ResidentBecameSheriff.create() unless ActionResultType::ResidentBecameSheriff.exists?
ActionResultType::TellerVotes.create() unless ActionResultType::TellerVotes.exists?
ActionResultType::TerroristBomb.create() unless ActionResultType::TerroristBomb.exists?
ActionResultType::SingleRequired::MafiaMembers.create() unless ActionResultType::SingleRequired::MafiaMembers.exists?
ActionResultType::SelfGenerated::Residents.create() unless ActionResultType::SelfGenerated::Residents.exists?
ActionResultType::JournalistInvestigate.create() unless ActionResultType::JournalistInvestigate.exists?
ActionResultType::DeputyIdentities.create() unless ActionResultType::DeputyIdentities.exists?
ActionResultType::ResidentBecameDeputy.create() unless ActionResultType::ResidentBecameDeputy.exists?
ActionResultType::SelfGenerated::ActionTypeParams.create() unless ActionResultType::SelfGenerated::ActionTypeParams.exists?
ActionResultType::GameOver.create() unless ActionResultType::GameOver.exists?
ActionResultType::ElderVote.create() unless ActionResultType::ElderVote.exists?

ActionResultType::RevivalOccurred.create() unless ActionResultType::RevivalOccurred.exists?
ActionResultType::RevivalRevealed.create() unless ActionResultType::RevivalRevealed.exists?

ActionResultType::ForgerVote.create() unless ActionResultType::ForgerVote.exists?


# roles has action types

Role.all.each { |role|
  if role.id != Role::FUGITIVE &&
    role.id != Role::ELDER &&
    role.id != Role::FORGER &&
    role.id != Role::ZOMBIE
    RoleHasActionType.create(:role_id => role.id, :action_type_id => ActionType::VOTE) unless RoleHasActionType.exists?(:role_id => role.id, :action_type_id => ActionType::VOTE) # everyone can Vote, except Fugitive, Elder and Zombie
  end
  RoleHasActionType.create(:role_id => role.id, :action_type_id => ActionType::RESIDENTS) unless RoleHasActionType.exists?(:role_id => role.id, :action_type_id => ActionType::RESIDENTS) # everyone can see other residents i.e. their status (alive / dead)
}

RoleHasActionType.create(:role_id => Role::DOCTOR, :action_type_id => ActionType::PROTECT) unless RoleHasActionType.exists?(:role_id => Role::DOCTOR, :action_type_id => ActionType::PROTECT) # doctor can Protect
RoleHasActionType.create(:role_id => Role::DETECTIVE, :action_type_id => ActionType::INVESTIGATE) unless RoleHasActionType.exists?(:role_id => Role::DETECTIVE, :action_type_id => ActionType::INVESTIGATE) # detective can Investigate
RoleHasActionType.create(:role_id => Role::SHERIFF, :action_type_id => ActionType::SHERIFF_IDENTITIES) unless RoleHasActionType.exists?(:role_id => Role::SHERIFF, :action_type_id => ActionType::SHERIFF_IDENTITIES) # sheriff can SheriffIdentities

RoleHasActionType.create(:role_id => Role::TELLER, :action_type_id => ActionType::TELLER_VOTES) unless RoleHasActionType.exists?(:role_id => Role::TELLER, :action_type_id => ActionType::TELLER_VOTES) # teller can TellerVotes
RoleHasActionType.create(:role_id => Role::TERRORIST, :action_type_id => ActionType::TERRORIST_BOMB) unless RoleHasActionType.exists?(:role_id => Role::TERRORIST, :action_type_id => ActionType::TERRORIST_BOMB) # terrorist can TerroristBomb

Role.where(:affiliation_id => Affiliation::MAFIA).each { |role|
  RoleHasActionType.create(:role_id => role.id, :action_type_id => ActionType::VOTE_MAFIA) unless RoleHasActionType.exists?(:role_id => role.id, :action_type_id => ActionType::VOTE_MAFIA) # every mafia member can vote for mafia kill
  if role.id != Role::ZOMBIE
    RoleHasActionType.create(:role_id => role.id, :action_type_id => ActionType::MAFIA_MEMBERS) unless RoleHasActionType.exists?(:role_id => role.id, :action_type_id => ActionType::MAFIA_MEMBERS) # every mafia member (except Zombie) can see other mafia members
  end
}

RoleHasActionType.create(:role_id => Role::JOURNALIST, :action_type_id => ActionType::JOURNALIST) unless RoleHasActionType.exists?(:role_id => Role::JOURNALIST, :action_type_id => ActionType::JOURNALIST)

RoleHasActionType.create(:role_id => Role::DEPUTY, :action_type_id => ActionType::DEPUTY_IDENTITIES) unless RoleHasActionType.exists?(:role_id => Role::DEPUTY, :action_type_id => ActionType::DEPUTY_IDENTITIES) # Deputy can DeputyIdentities
RoleHasActionType.create(:role_id => Role::ELDER, :action_type_id => ActionType::ELDER_VOTE) unless RoleHasActionType.exists?(:role_id => Role::ELDER, :action_type_id => ActionType::ELDER_VOTE) # Elder can ElderVote

RoleHasActionType.create(:role_id => Role::NECROMANCER, :action_type_id => ActionType::INITIATE_REVIVAL) unless RoleHasActionType.exists?(:role_id => Role::NECROMANCER, :action_type_id => ActionType::INITIATE_REVIVAL) # Necromancer can InitiateRevival
RoleHasActionType.create(:role_id => Role::NECROMANCER, :action_type_id => ActionType::REVIVE) unless RoleHasActionType.exists?(:role_id => Role::NECROMANCER, :action_type_id => ActionType::REVIVE) # Necromancer can Revive

RoleHasActionType.create(:role_id => Role::FORGER, :action_type_id => ActionType::FORGER_VOTE) unless RoleHasActionType.exists?(:role_id => Role::FORGER, :action_type_id => ActionType::FORGER_VOTE) # Forger can ForgerVote


# action resolvers

ActionResolver::ProtectVoteMafia.create() unless ActionResolver::ProtectVoteMafia.exists?
ActionResolver::JournalistInvestigateVoteMafia.create() unless ActionResolver::JournalistInvestigateVoteMafia.exists?
ActionResolver::VoteTellerVotesSGResidents.create() unless ActionResolver::VoteTellerVotesSGResidents.exists?
ActionResolver::VoteElderVote.create() unless ActionResolver::VoteElderVote.exists?
ActionResolver::TellerVotesSelfGeneratedActionTypeParams.create() unless ActionResolver::TellerVotesSelfGeneratedActionTypeParams.exists?
ActionResolver::VoteTransform.create() unless ActionResolver::VoteTransform.exists?
ActionResolver::ValidVoidVoteMafia.create() unless ActionResolver::ValidVoidVoteMafia.exists?
ActionResolver::ValidVoidVote.create() unless ActionResolver::ValidVoidVote.exists?
ActionResolver::VoteMafiaImplement.create() unless ActionResolver::VoteMafiaImplement.exists?
ActionResolver::VoteImplement.create() unless ActionResolver::VoteImplement.exists?
ActionResolver::TerroristBombSelfGeneratedResidents.create() unless ActionResolver::TerroristBombSelfGeneratedResidents.exists?
ActionResolver::SelfGeneratedResidentsRefresher.create() unless ActionResolver::SelfGeneratedResidentsRefresher.exists?
ActionResolver::SheriffIdentitiesSelfGeneratedResidents.create() unless ActionResolver::SheriffIdentitiesSelfGeneratedResidents.exists?
ActionResolver::SheriffIdentitiesSelfGeneratedActionTypeParams.create() unless ActionResolver::SheriffIdentitiesSelfGeneratedActionTypeParams.exists?
ActionResolver::SheriffSelfGeneratedResidents.create() unless ActionResolver::SheriffSelfGeneratedResidents.exists?
ActionResolver::GameOver.create() unless ActionResolver::GameOver.exists?
ActionResolver::DeputyIdentitiesSelfGeneratedResidents.create() unless ActionResolver::DeputyIdentitiesSelfGeneratedResidents.exists?
ActionResolver::DeputyIdentitiesSelfGeneratedActionTypeParams.create() unless ActionResolver::DeputyIdentitiesSelfGeneratedActionTypeParams.exists?
ActionResolver::DeputySelfGeneratedResidents.create() unless ActionResolver::DeputySelfGeneratedResidents.exists?
ActionResolver::InvestigateSelfGeneratedActionTypeParams.create() unless ActionResolver::InvestigateSelfGeneratedActionTypeParams.exists?
ActionResolver::JournalistInvestigateSelfGeneratedActionTypeParams.create() unless ActionResolver::JournalistInvestigateSelfGeneratedActionTypeParams.exists?
ActionResolver::ProtectSelfGeneratedActionTypeParams.create() unless ActionResolver::ProtectSelfGeneratedActionTypeParams.exists?
ActionResolver::RevivalOccurredSelfGeneratedResidents.create() unless ActionResolver::RevivalOccurredSelfGeneratedResidents.exists?
ActionResolver::ReviveSelfGeneratedActionTypeParams.create() unless ActionResolver::ReviveSelfGeneratedActionTypeParams.exists?
ActionResolver::VoteForgerVote.create() unless ActionResolver::VoteForgerVote.exists?


# game end conditions

GameEndCondition::CitizensVsMafia.create(:name =>'Citizens vs. Mafia', :description => "The game ends if, at the moment of day start or night start, one of the following conditions are met:\n 1) all mafia members are dead, \n2) mafia members consist >=50% of living population in a city.") unless GameEndCondition::CitizensVsMafia.exists?

# self generated result types
CityHasSelfGeneratedResultType.create(:action_result_type_id => ActionResultType::RESIDENTS) unless CityHasSelfGeneratedResultType.exists?(:action_result_type_id => ActionResultType::RESIDENTS)
CityHasSelfGeneratedResultType.create(:action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS) unless CityHasSelfGeneratedResultType.exists?(:action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS)

# triggers

Trigger.create(:name => 'night start', :description => 'Triggers only at night start.') unless Trigger.exists?(:name => 'night start')
Trigger.create(:name => 'day start', :description => 'Triggers only at day start.') unless Trigger.exists?(:name => 'day start')
Trigger.create(:name => 'both', :description => 'Triggers both at night start and day start.') unless Trigger.exists?(:name => 'both')
Trigger.create(:name => 'async', :description => 'Triggering is asynchronous.') unless Trigger.exists?(:name => 'async')
Trigger.create(:name => 'no trigger', :description => 'Never triggers.') unless Trigger.exists?(:name => 'no trigger')



# app roles

super_admin_app_role = AppRole.find_or_create_by(:name => 'Super Admin')
admin_app_role = AppRole.find_or_create_by(:name => 'Admin')
game_creator_app_role = AppRole.find_or_create_by(:name => 'Game Creator')
user_app_role = AppRole.find_or_create_by(:name => 'User')


app_permissions = []
can_participate_app_permission = AppPermission.find_or_create_by(:name => 'Permission to participate in games')
app_permissions << can_participate_app_permission
can_create_games_app_permission = AppPermission.find_or_create_by(:name => 'Permission to create games')
app_permissions << can_create_games_app_permission
can_access_admin_panel_readonly = AppPermission.find_or_create_by(:name => 'Permission to access admin panel in readonly mode')
app_permissions << can_access_admin_panel_readonly

admin_app_role.app_permissions = app_permissions.dup()
admin_app_role.save()

can_access_admin_panel_rw = AppPermission.find_or_create_by(:name => 'Permission to read and write inside admin panel')
app_permissions << can_access_admin_panel_rw


super_admin_app_role.app_permissions = app_permissions
super_admin_app_role.save()


user_app_role.app_permissions << can_participate_app_permission
user_app_role.save()

game_creator_app_role.app_permissions << can_participate_app_permission
game_creator_app_role.app_permissions << can_create_games_app_permission
game_creator_app_role.save()



# payment types

PaymentType::Unknown.create(:name => 'Unknown', :description => 'Payment received with unknown purpose.') unless PaymentType::Unknown.exists?
PaymentType::Subscription1Month.create(:name => 'Subscription 1 Month', :description => 'User receives privileges to create and run games for one month.') unless PaymentType::Subscription1Month.exists?
PaymentType::Subscription1Year.create(:name => 'Subscription 1 Year', :description => 'User receives privileges to create and run games for one year.') unless PaymentType::Subscription1Year.exists?
PaymentType::Buy1Game.create(:name => 'Buy 1 Game', :description => 'User can create and start one game. User utilizes this purchase when a game they created is started. If a user creates a game and cancels it before it has been started, this game is not charged.') unless PaymentType::Buy1Game.exists?
PaymentType::Buy5Game.create(:name => 'Buy 5 Games', :description => 'User can create and start five games. User expends one game at a time every time a game is started. If a user creates a game and cancels it before it has been started, this game is not charged.') unless PaymentType::Buy5Game.exists?
PaymentType::Buy1RolePick.create(:name => 'Buy 1 Role Pick', :description => 'After user joins a game and before the game is started, user can choose which roles he/she prefers to be in the game that is about to start. Role Pick is utilized and expended when a game starts and the user is assigned one of the roles they preferred before the game has started. If a game has started and the user is not assigned the role he/she wanted, Role Pick is not expended and can be used in a different game. If too many users pick the same role and everybody\'s preference cannot be satisfied, the users that submitted their preferences earlier take precedence.') unless PaymentType::Buy1RolePick.exists?
PaymentType::Buy5RolePick.create(:name => 'Buy 5 Role Picks', :description => 'After user joins a game and before the game is started, user can choose which roles he/she prefers to be in the game that is about to start. Role Pick is utilized and expended when a game starts and the user is assigned one of the roles they preferred before the game has started. If a game has started and the user is not assigned the role he/she wanted, Role Pick is not expended and can be used in a different game. If too many users pick the same role and everybody\'s preference cannot be satisfied, the users that submitted their preferences earlier take precedence.') unless PaymentType::Buy5RolePick.exists?









