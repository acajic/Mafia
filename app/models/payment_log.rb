class PaymentLog < ActiveRecord::Base

  belongs_to :payment_type
  belongs_to :user
  has_many :subscription_purchases, :dependent => :destroy
  has_many :game_purchases, :dependent => :destroy
  has_many :role_pick_purchases, :dependent => :destroy

  attr_accessor :info


  validates :user_id, :presence => true
  validates :payment_type_id, :presence => true

  before_save :serialize_info, :adjust_total_price, :adjust_user_email


  def info
    if @info.nil? && !self.info_json.blank?
      @info = JSON.parse(self.info_json)
    end

    @info
  end



  def self.init_hash(param_payment_log_hash)
    payment_log_hash = {}

    user_hash = param_payment_log_hash.require(:user)
    payment_log_hash[:user] = User.find(user_hash.require(:id))

    payment_type_hash = param_payment_log_hash.require(:payment_type)
    payment_log_hash[:payment_type] = PaymentType.find(payment_type_hash.require(:id))

    payment_log_hash
  end

  def as_json(options={})
    {
        :id => self.id,
        :user_id => self.user_id,
        :user_email => self.user_email,
        :user => self.user || {},
        :payment_type => self.payment_type,
        :unit_price => self.unit_price,
        :quantity => self.quantity,
        :total_price => self.total_price,
        :info => self.info(),
        :is_payment_valid => self.is_payment_valid,
        :is_sandbox => self.is_sandbox,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }
  end

  private

  #before_save

  def serialize_info
    if self.info_json.nil? && !@info.nil?
      self.info_json = @info.to_json()
    end
  end

  def adjust_total_price
    self.total_price = self.unit_price * self.quantity
  end

  def adjust_user_email
    user = User.find(self.user_id)
    if user
      self.user_email = user.email
    end
  end

end
