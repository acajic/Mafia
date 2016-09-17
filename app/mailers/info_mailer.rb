class InfoMailer < ActionMailer::Base
  default from: 'noreplymafia@gmail.com'

  CLIENT_HOST = 'http://exposemafia.com'
  CLIENT_HOST_CITIES = CLIENT_HOST + '/cities'
  UNSUBSCRIBE_URL = CLIENT_HOST + '/unsubscribe'

  def should_send_to_email(email)
    if /@email.com$/ =~ email
      return false
    end

    true
  end

  def send_email_confirmation_mail(user)
    # default_url_options = self.default_url_options()

    @user = user
    @url = url_for(:controller => 'users', :action => 'confirm_email', :email_confirmation_code => @user.email_confirmation_code)
    if should_send_to_email(@user.email)
      mail(:to => @user.email, :subject => 'Confirm Email').deliver()
    end

  end

  def confirm_user_forgot_password(user)
    @user = user
    @url = url_for(:controller => 'users', :action => 'confirm_forgot_password', :email_confirmation_code => @user.email_confirmation_code)
    if should_send_to_email(@user.email)
      mail(:to => @user.email, :subject => 'Confirm Request To Reset Password').deliver()
    end

  end

  def send_password_to_user_after_reset(user, password)
    @user = user
    @password = password
    @url = CLIENT_HOST_CITIES
    mail(:to => @user.email, :subject => 'Password Reset').deliver()
  end

  def welcome_user_and_send_password(user, password)
    @user = user
    @password = password
    @url = CLIENT_HOST_CITIES + '/email_confirmation/' + @user.email_confirmation_code

    if should_send_to_email(@user.email)
      mail(:to => @user.email, :subject => 'Welcome to Mafia').deliver()
    end

  end

  def notify_users_added_to_game(users, city, user_creator)

    @url = CLIENT_HOST_CITIES
    @city = city
    @user_creator = user_creator
    @unsubscribe_url = UNSUBSCRIBE_URL

    emails = users.select {|u|
      !u.email.nil? &&
      !u.email.empty? &&
      (u.user_preference ? u.user_preference.receive_notifications_when_added_to_game : true)  &&
      should_send_to_email(u.email)
    }.map { |u| u.email }.join(',')

    if emails.empty?
      return
    end
    mail(:to => emails, :subject => user_creator.username + ' added you to the game ' + city.name + '.').deliver()
  end


  def notify_users_invited_to_game(users, city, user_creator)
    @url = CLIENT_HOST_CITIES
    @city = city
    @user_creator = user_creator
    @unsubscribe_url = UNSUBSCRIBE_URL

    emails = users.select { |u|
      !u.email.nil? &&
      !u.email.empty? &&
      (u.user_preference ? u.user_preference.receive_notifications_when_added_to_game : true) &&
      should_send_to_email(u.email)
    }.map { |u| u.email }.join(',')

    if emails.empty?
      return
    end
    mail(:to => emails, :subject => user_creator.username + ' invited you to the game ' + city.name + '.').deliver()
  end


  def notify_user_join_request_accepted(user, city, user_creator)
    @url = CLIENT_HOST_CITIES
    @city = city
    @user_creator = user_creator
    @user = user
    @unsubscribe_url = UNSUBSCRIBE_URL

    if should_send_to_email(user.email)
      mail(:to => user.email, :subject => 'Your request to join "' + city.name + '" has been accepted.').deliver()
    end
  end

end

