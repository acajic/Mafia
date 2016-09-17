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
