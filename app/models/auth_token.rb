class AuthToken < ActiveRecord::Base
  belongs_to :user

  # attr_accessible :user, :user_id, :token_string, :expiration_date

  attr_accessor :last_accessed

  after_initialize :accessed

  before_create :set_token_string_expiration_date

  def accessed
    self.last_accessed = Time.now.utc
  end

  def set_token_string_expiration_date
    if self.user_id == nil
      return false
    end
    self.token_string = Digest::SHA2.hexdigest("#{self.user_id}#{Time.now.utc}")
    self.expiration_date = 2400.hours.from_now
  end

  def self.remove_expired_tokens
    self.where("expiration_date < ?", Time.now.utc).destroy_all
  end

  def as_json(options={})
    {
        :user_id => self.user_id,
        :token_string => self.token_string,
        :expiration_date => self.expiration_date
    }
  end
end
