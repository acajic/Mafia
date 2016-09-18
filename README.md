Mafia server side
==========

# Setup

Here are the instructions on how to setup the server side of the Mafia web app after pulling the Git repository. If you want the corresponding front end, the repository is https://github.com/acajic/MafiaFront

1) config/database.yml
Set up the username, password and ip address of your SQL server.

2) run "rake db:setup RAILS_ENV=production"
Or whichever environment.

Development and test environment come with database pre-populated with some users.
Production comes with empty database. The first registered user is automatically assigned the role of Super Admin. This role cannot be transferred!

3) Search the project for comment "# initial setup" and fill out the variables specified in various config files.
These variables include:
	
	*config.action_mailer.smtp_settings* (here I used sendgrid.net service, my username and password from that site and the exposemafia.com as the domain)
	
	*config.action_mailer.default_url_options* (here I used :host => 'http://188.226.245.205:3000' because it is a root url on which all other build upon in my case. This is for normal functioning of the mailer. So, whatever you put here, it will be easy to test whether all the links work in emails that app sends to users upon registration or invitation to a game.)
	

# Database
	
![Database Diagram](DatabaseDiagram.png)

Gray tables are not relevant to the game. They are some side functionalities.

Purple tables are about system roles and app permissions (super admin, admin, game creator, user).

Dark blue tables are the ones that are used throughout the game but their contents never change after the app is deployed. Only after an update will, for example, a new role be offered for players to play with.

Light blue tables are the most active ones.

# Workflow

U person visits a site and registers. This creates a record in the `users` table. It also creates one record in `user_preferences` table, it is a 1-to-1 mapping.
Whenever user logs in, they are assigned a authorization token. These are stored in `auth_tokens` table.

Whenever a new game is created, a record in `cities` table is generated. For all future references, cities ARE separate instances of games. 'Towns' may be more appropriate table name, but 'cities' stuck around as a legacy code.

When a user joins a game, they become `residents` of that `city`. So, a `resident` belongs to 1 `city` and to 1 `user`. A `resident` is assigned a true `role` but it also holds the information about the role that the player is currently assuming within the game - via `saved_role_id`.

During the course of a game, a user that is a resident of the city can submit `actions`. There are different types of actions that a resident can submit. All of the action types are available in the corresponding table `action_types`. When submitting an action, resident also specifies as what `role` is submitting that action. A resident can assume any role, and submit any action with any role. It is only at the `trigger` time of each of these actions that it will be determined whether the action was **valid**, **void** or **malformed**. The result of each action is determined based on this evaluation.

Triggers are: 
1. night start
2. day start
3. both
4. async
5. no trigger

Both valid and void actions at the trigger time produce `action_results`. Malformed actions are disregarded and they do not produce any results whatsoever.

If a resident submits actions as their own true game role, then the actions are **valid**. E.g. a user that was assigned the role of a detective at the beginning of the game submits actions as a detective.

If a user changes his own operating role, his actions will be processed as **void**. E.g. although a user was assigned the role of a detective at the beginning of the game, they changed the role to doctor in order to submit the action specific to that role.

If a user submits a non-sensible action, it is marked as **malformed** and disregarded. E.g. user assumes the role of a doctor and submits an investigation action that is allowed only to a detective role.

Valid actions produce the exact results as one would expect. Detective investigations yield reliable information, doctor's protection provides certainty that a protected player will not be murdered in the upcoming night.

Void action do not affect the state of the game and the information received from the actions are random and unreliable. E.g. User assumes a fake role of a detective and performs investigation. At the trigger time, the game will give a random response regarding whether the investigated player is a mafia or not. The information may be true and it may be false. The player performing the action knows that he cannot trust the obtained information.
Another example, a teller receives a number of votes in the last lynch voting (who got how many votes). If a player is faking the teller role and tries to obtain the information about who got how many votes, the app will generate a fake data. The fake data will not be completely random, though. It will be random but it will always stay consistent with the result of the voting. If player A was voted out, the votes distribution will necessarily corroborate that event and make sure that the fake data shows that player A received the majority of the votes.


After the actions are processed at their trigger times, `action_results` are produced. Each action result is like a single item in the player's news feed when the log into the game.

Some action results are not caused by actions. These are called 'self generated' action results.
Some action results do not appear in the news feed. Like the self generated action result that contains a list of all residents and their statuses - dead/alive. For each game day, this action result is generated. In the basic setup, an identical list of residents' statuses will be sent to each player via action result. But this opens a way for interesting future roles that can cause other players to start receiving fake data.

A user can generate any `action_result` manually. By doing this, a player is merely generating a notification that will appear in their news feed. They are not in fact affecting the state of the game. By making someone appear dead in the list of your action results, does not in fact make that player dead.
Every `action_result` is of certain `action_result_type`.

There is one more special subgroup of `action_types` and 'action_result_types'. These are labeled 'single required'. When a trigger time comes for one of such actions, if a user hasn't performed the action it automatically performed for the user. Based on this automatically submitted action, an `action_result` is generated just as if the user manually submitted the `action`. 


Each game `role` belongs to an `affiliation`. Only `affiliations` can actually win or lose games.

Each `role` has on disposal certain `action_types`. Some `action_types` have `action_type_params`. These are usually numerical variables that modify the action type. For example, a detective's investigate action can be modified such that a detective only has the option to use his investigation ability 3 or 4 times during entire game.


At night start or day start, many actions hit their trigger. There are a lot of various action types that cannot be evaluated simply on their own. For example, the success of mafia nightkill voting will certaintly depend on the doctors actions or the absence of them. This is where `action_resolvers` come to play. At 'night start' and 'day start' triggers, a list of action resolvers are employed to make final changes to the game state based on the sum of all unprocessed actions. Each `action_resolver` has the **ordinal** parameter - a number that specifies the order of the executions of action resolvers.