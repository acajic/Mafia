temp_initial_app_role = InitialAppRole.create(:description => 'Temporary initial app role for creating users during seed.', :email_pattern => '@email.com$')

# users
User.create(:username => 'AndrijaCajic', :email => 'ancajic@gmail.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user2', :email => 'user2@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user3', :email => 'user3@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user4', :email => 'user4@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user5', :email => 'user5@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user6', :email => 'user6@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user7', :email => 'user7@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user8', :email => 'user8@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user9', :email => 'user9@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user10', :email => 'user10@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user11', :email => 'user11@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user12', :email => 'user12@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user13', :email => 'user13@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user14', :email => 'user14@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user15', :email => 'user15@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user16', :email => 'user16@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user17', :email => 'user17@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user18', :email => 'user18@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user19', :email => 'user19@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user20', :email => 'user20@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user21', :email => 'user21@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user22', :email => 'user22@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user23', :email => 'user23@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user24', :email => 'user24@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user25', :email => 'user25@email.com', :password => 'password', :email_confirmed => true)
User.create(:username => 'user26', :email => 'user26@email.com', :password => 'password', :email_confirmed => true)


temp_initial_app_role.destroy()


# cities with day cycles and residents

duration = 180
start = 0
day_cycles = []
while start < 24*60 - duration*2
  day_cycles << DayCycle.new(:day_start => start, :night_start => start + duration)
  start += duration*2
end


residents = []

residents << Resident.new(:user_id => 1)
residents << Resident.new(:user_id => 2)
residents << Resident.new(:user_id => 3)
residents << Resident.new(:user_id => 4)
residents << Resident.new(:user_id => 5)
residents << Resident.new(:user_id => 6)
residents << Resident.new(:user_id => 7)
residents << Resident.new(:user_id => 8)
residents << Resident.new(:user_id => 9)
residents << Resident.new(:user_id => 10)
residents << Resident.new(:user_id => 11)
residents << Resident.new(:user_id => 12)
residents << Resident.new(:user_id => 13)
residents << Resident.new(:user_id => 14)
residents << Resident.new(:user_id => 15)
residents << Resident.new(:user_id => 16)
residents << Resident.new(:user_id => 17)
residents << Resident.new(:user_id => 18)
residents << Resident.new(:user_id => 19)
residents << Resident.new(:user_id => 20)

city = City.create(:name => 'city1', :user_creator_id => 1, :timezone => 2*60, :day_cycles => day_cycles, :residents => residents)


# city has game end conditions

CityHasGameEndCondition.create(:city_id => 1, :game_end_condition_id => GameEndCondition::CITIZENS_VS_MAfIA)


# city has self generated types

CityHasSelfGeneratedResultType.create(:city_id => 1, :action_result_type_id => ActionResultType::RESIDENTS)
CityHasSelfGeneratedResultType.create(:city_id => 1, :action_result_type_id => ActionResultType::ACTION_TYPE_PARAMS)


# city has roles
# city.set_role_quantities()

# city days
# city.days << Day.create(:number => 0)
city.save
