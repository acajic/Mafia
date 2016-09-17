class GrantedAppRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscription_purchase
  belongs_to :app_role

  validates :user_id, :presence => true
  validate :app_role_granted_not_to_super_admin, :super_admin_app_role_cannot_be_granted

  def self.init_hash(param_granted_app_role_hash)
    granted_app_role_hash = {}

    user = User.find(param_granted_app_role_hash.require(:user).require(:id))
    granted_app_role_hash[:user] = user

    if param_granted_app_role_hash[:subscription_purchase]
      subscription_purchase = SubscriptionPurchase.find(param_granted_app_role_hash[:subscription_purchase][:id])
      granted_app_role_hash[:subscription_purchase] = subscription_purchase
    end

    app_role = AppRole.find(param_granted_app_role_hash.require(:app_role).require(:id))
    granted_app_role_hash[:app_role] = app_role

    granted_app_role_hash[:description] = param_granted_app_role_hash[:description]
    granted_app_role_hash[:expiration_date] = param_granted_app_role_hash[:expiration_date]



    granted_app_role_hash
  end


  def as_json(options={})
    {
        :id => self.id,
        :description => self.description,
        :user_id => self.user_id,
        :user => self.user,
        :app_role => self.app_role,
        :expiration_date => self.expiration_date,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }
  end

  private

  def app_role_granted_not_to_super_admin
    if self.user.default_app_role_id == AppRole::SUPER_ADMIN
      errors.add(:user_id, 'must not be the super admin')
    end
  end

  def super_admin_app_role_cannot_be_granted
    if self.app_role_id == AppRole::SUPER_ADMIN
      errors.add(:app_role_id, 'Super Admin app role cannot be granted')
    end
  end

  def same_user_as_subcription_purchase
    if self.subscription_purchase
      if self.subscription_purchase.user_id != self.user_id
        errors.add(:subscription_purchase_id, 'GrantedAppRole.user_id does not match to SubscriptionPurchase.user_id')
      end
    end
  end

end
