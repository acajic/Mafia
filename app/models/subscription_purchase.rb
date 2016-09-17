class SubscriptionPurchase < ActiveRecord::Base

  belongs_to :payment_log
  belongs_to :user

  validates :user_id, :presence => true

  before_save :adjust_user_based_on_payment_log
  after_save :recreate_granted_app_role_if_necessary

  TYPE_1_MONTH = 1
  TYPE_1_YEAR = 2


  def self.init_hash(param_subscription_purchase_hash)
    subscription_purchase_hash = {}

    if param_subscription_purchase_hash[:payment_log].blank? || param_subscription_purchase_hash[:payment_log][:id].blank?
      subscription_purchase_hash[:user] = User.find(param_subscription_purchase_hash.require(:user).require(:id))
      subscription_purchase_hash[:payment_log] = nil
    else
      payment_log = PaymentLog.find(param_subscription_purchase_hash.require(:payment_log).require(:id))

      subscription_purchase_hash[:payment_log] = payment_log
      subscription_purchase_hash[:user] = payment_log.user
    end
    subscription_purchase_hash[:expiration_date] = param_subscription_purchase_hash[:expiration_date]
    subscription_purchase_hash[:subscription_type] = param_subscription_purchase_hash[:subscription_type]

    subscription_purchase_hash
  end

  def as_json(options={})
    {
        :id => self.id,
        :payment_log => self.payment_log || {},
        :user_id => self.user_id,
        :user => self.user || {},
        :user_email => self.user_email,
        :subscription_type => self.subscription_type,
        :expiration_date => self.expiration_date,
        :is_active => self.expiration_date ? self.expiration_date >= Time.now : false,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }

  end

  private

  #before_save
  def adjust_user_based_on_payment_log
    if self.payment_log
      self.user = self.payment_log.user
    end
    if self.user
      self.user_email = self.user.email
    end
  end


  #after_save
  def recreate_granted_app_role_if_necessary
    granted_app_roles = GrantedAppRole.where(:subscription_purchase_id => self.id)
    granted_app_role_found = nil
    if granted_app_roles.count > 0

      granted_app_roles.each { |granted_app_role|
        if granted_app_role.user_id == self.user_id
          granted_app_role_found = granted_app_role
        else
          granted_app_role.destroy()
        end
      }
    end

    if granted_app_role_found
      granted_app_role_found.update_attributes(:expiration_date => self.expiration_date)
    else
      GrantedAppRole.create(:user => self.user, :subscription_purchase => self, :app_role_id => AppRole::GAME_CREATOR, :expiration_date => self.expiration_date)
    end
  end

end
