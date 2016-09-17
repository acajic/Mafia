class GamePurchase < ActiveRecord::Base

  belongs_to :payment_log
  belongs_to :user
  # delegate :user, :to => :payment_log, :allow_nil => true

  belongs_to :city

  validates :user_id, :presence => true

  validate :validate_city_started


  before_save :adjust_user_based_on_payment_log, :adjust_city_name

  def self.init_hash(param_game_purchase_hash)
    game_purchase_hash = {}

    if param_game_purchase_hash[:payment_log].blank? || param_game_purchase_hash[:payment_log][:id].blank?
      user = User.find(param_game_purchase_hash.require(:user).require(:id))
      game_purchase_hash[:user] = user
      game_purchase_hash[:payment_log] = nil
    else
      payment_log = PaymentLog.find(param_game_purchase_hash.require(:payment_log).require(:id))
      game_purchase_hash[:payment_log] = payment_log
      game_purchase_hash[:user] = payment_log.user
    end


    if param_game_purchase_hash[:city].blank?
      # nothing
    else
      city_hash = param_game_purchase_hash[:city]
      game_purchase_hash[:city] = GamePurchase.find(city_hash.require(:id))
    end

    game_purchase_hash
  end


  def as_json(options={})
    {
        :id => self.id,
        :payment_log => self.payment_log,
        :user_id => self.user_id,
        :user_email => self.user_email,
        :user => self.user || {},
        :city_id => self.city_id,
        :city_name => self.city_name,
        :city_started_at => self.city_started_at,
        :city => self.city || {},
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }

  end


  private

  #validation
  def validate_city_started
    if self.city
      if self.city.started_at.nil?
        errors.add(:city_id, 'City has to be started for it to be assigned to a GamePurchase model.')
      end
    end
  end

  #before_save
  def adjust_user_based_on_payment_log
    if self.payment_log
      self.user = self.payment_log.user
    end
    if self.user
      self.user_email = self.user.email
    end

  end

  def adjust_city_name
    if self.city
      self.city_name = self.city.name
    end
  end

end
