class RolePickPurchase < ActiveRecord::Base

  belongs_to :payment_log
  belongs_to :user

  #  delegate :user, :to => :payment_log, :allow_nil => true

  belongs_to :role_pick

  validates :user_id, :presence => true
  # validate :validate_city_started
  # validate :validate_resident_assigned_proper_role

  before_save :adjust_user_based_on_payment_log




  def self.init_hash(param_role_pick_purchase)
    role_pick_purchase_hash = {}

    if param_role_pick_purchase[:payment_log].blank? || param_role_pick_purchase[:payment_log][:id].blank?
      user = User.find(param_role_pick_purchase.require(:user).require(:id))
      role_pick_purchase_hash[:payment_log] = nil
    else
      payment_log = PaymentLog.find(param_role_pick_purchase.require(:payment_log).require(:id))
      role_pick_purchase_hash[:payment_log] = payment_log
      user = payment_log.user
    end

    role_pick_purchase_hash[:user] = user

    role_pick_hash = param_role_pick_purchase[:role_pick]

    if role_pick_hash[:city].blank? || role_pick_hash[:role].blank?
      # nothing
    else
      city = City.find(role_pick_hash.require(:city).require(:id))
      role = Role.find(role_pick_hash.require(:role).require(:id))
      role_pick = RolePick.new(:user => user, :city => city, :role => role)
      role_pick_purchase_hash[:role_pick] = role_pick
    end

    role_pick_purchase_hash
  end


  def as_json(options={})
    {
        :id => self.id,
        :payment_log => self.payment_log,
        :user_id => self.user_id,
        :user_email => self.user_email,
        :user => self.user || {},
        :role_pick => self.role_pick || {},
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }
  end

  private

  # validation

=begin

  def validate_city_started
    if self.role_pick
      logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())
      # this means that the RolePickPurchase is being labeled as 'used'
      if self.role_pick.city.nil?
        errors.add(:role_pick_id, 'RolePick must have city.')
        logger.error('RolePick must have city. RolePurchase: ' + self.to_json())
      else
        if self.role_pick.city.started_at.nil?
          errors.add(:role_pick_id, 'RolePick must have a city that is started.')
          logger.error('RolePick must have a city that is started. RolePurchase: ' + self.to_json())
        end
      end
    end
  end
=end



=begin

  def validate_resident_assigned_proper_role
    if self.role_pick
      logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())
      # this means that the RolePickPurchase is being labeled as 'used'
      user = self.role_pick.user
      city = self.role_pick.city
      resident = city.residents.where(:user_id => user.id).first()
      if resident.nil?
        errors.add(:user_id, "User [#{user.id} #{user.username}] is not a participant in the game [#{city.id} #{city.name}]")
        logger.error("User [#{user.id} #{user.username} is not a participant in the game [#{city.id} #{city.name}]. RolePurchase: " + self.to_json())
        return false
      end

      if resident.role_id != self.role_pick.role_id
        errors.add(:role_pick_id, 'RolePick.role_id must correspond to actual role assigned to the resident.')
        logger.error('RolePick.role_id must correspond to actual role assigned to the resident. RolePurchase: ' + self.to_json())
        return false
      end
    end
  end
=end


  #before_save

  def adjust_user_based_on_payment_log
    if self.payment_log
      self.user = self.payment_log.user
    end
    if self.user
      self.user_email = self.user.email
    end
  end

end
