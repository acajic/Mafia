module ApipieParams::User
  extend Apipie::DSL::Concern

  def_param_group :new_user do
    param :user, Hash, :desc => 'User', :required => true do
      param :username, String, :desc => 'Username', :required => true
      param :email, String, :desc => 'Email', :required => true
      param :password, String, :desc => 'Password in plaintext. Password does not get stored in the database in plaintext.', :required => true
      param :repeat_password, String, :desc => 'Repeat password', :required => true

    end

  end


  UPDATE_USER_DESC = '
  {
    user: {
        id: 21,
        username: "user21",
        email: "user21altered@email.com",
        user_preference: {
            id: 21,
            user_id: 21,
            receive_notifications_when_added_to_game: true,
            automatically_join_when_invited: true,
            created_at: "2015-02-08T20:03:49.000Z",
            updated_at: "2015-02-08T20:03:49.000Z"
        },
        app_role: {
            id: 4,
            name: "User",
            app_permissions: {
                1: {
                    id: 1,
                    name: "Permission to participate in games",
                    created_at: "2015-02-08T20:03:47.000Z",
                    updated_at: "2015-02-08T20:03:47.000Z"
                }
            }
        },
        hashed_password: "d8eddb48a9102eef992810644dca45b43b1f362619ef4586d04c6cdae11e1e4b",
        password_salt: "user21",
        created_at: "2015-02-08T20:03:49.000Z",
        updated_at: "2015-02-08T20:03:49.000Z",
        auth_token: null,
        role_picks: null,
        game_purchases: null,
        unused_game_purchases: null,
        role_pick_purchases: null,
        unused_role_pick_purchases: null,
        subscription_purchases: null,
        active_subscription: null,
        password: "secretPassword"
    },
    auth_token: "ce5a189ec0807ce64e478b38cb6c379f558ecbf047ea63b4edf2fed12f63e494"
  }'


  def_param_group :update_user do
    param :user, Hash, :desc => 'User', :required => true do
      param :id, Integer, :desc => 'Id', :required => true
      param :username, String, :desc => 'Username', :required => false
      param :email, String, :desc => 'Email', :required => false
      param :user_preference, Hash, :desc => 'Email preferences', :required => false
      param :password, String, :desc => 'Password in plaintext. Password does not get stored in plaintext. Password is necessary in order to perform update.', :required => true
    end

  end

end