class JoinRequest < ActiveRecord::Base

  belongs_to :city
  belongs_to :user

  validates_uniqueness_of :user_id, scope: [:city_id]

  def as_json(options={})
    {
        :id => self.id,
        :city_id => self.city_id,
        :city_name => self.city.name,
        :user_id => self.user_id,
        :username => self.user.username,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }
  end

end
