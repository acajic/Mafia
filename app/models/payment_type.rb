class PaymentType < ActiveRecord::Base

  UNKNOWN = 1
  SUBSCRIPTION_1_MONTH = 2
  SUBSCRIPTION_1_YEAR = 3
  BUY_1_GAME = 4
  BUY_5_GAMES = 5
  BUY_1_ROLE_PICK = 6
  BUY_5_ROLE_PICKS = 7

end
