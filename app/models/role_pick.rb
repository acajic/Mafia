class RolePick < ActiveRecord::Base

  belongs_to :city
  belongs_to :user
  belongs_to :role
  has_one :role_pick_purchase

  validates :user_id, :presence => true
  validates :city_id, :presence => true
  validates :role_id, :presence => true

  validate :validate_user_is_resident_in_city

  before_save :adjust_city_name_and_started_at

  before_destroy :clear_role_pick_purchase


  def as_json(options={})
    {
        :id => self.id,
        :user_id => self.user_id,
        :username => self.user.username,
        :city_id => self.city_id,
        :city_name => self.city_name,
        :city_started_at => self.city_started_at,
        :role => self.role,
        :is_resolved => self.city_started_at != nil,
        :role_pick_purchase_id => self.role_pick_purchase ? self.role_pick_purchase.id : nil,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }

  end

  private

  def adjust_city_name_and_started_at
    if self.city
      self.city_name = self.city.name
      self.city_started_at = self.city.started_at
    end
  end

  def validate_user_is_resident_in_city
    residents = self.city.residents.where(:user_id => self.user_id)
    if residents.count == 0
      self.errors.add(:user_id, "User [#{self.user_id} #{self.user.username}] is not a resident in the city [#{self.city_id} #{self.city_name}]")
      return false
    end
  end


  def clear_role_pick_purchase
    if self.city_started_at
      self.role_pick_purchase.destroy()
    elsif self.role_pick_purchase
      self.role_pick_purchase.role_pick = nil
      self.role_pick_purchase.save()
    end
  end

end
