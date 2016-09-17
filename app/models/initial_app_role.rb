class InitialAppRole < ActiveRecord::Base

  belongs_to :app_role

  validate :validate_email_or_email_pattern

  def validate_email_or_email_pattern
    if (self.email.nil? || self.email.empty?) && (self.email_pattern.nil? || self.email_pattern.empty?)
      errors.add(:email, "Either 'email' or 'email_pattern' must be non-empty value. ")
    end
  end


  def self.app_role_for_email(email)
    initial_app_role = InitialAppRole.where(:email => email, :enabled => true).where('email IS NOT NULL').order('priority DESC').first

    app_role = nil
    if initial_app_role.nil?
      initial_app_roles = InitialAppRole.where(:enabled => true).where('email_pattern IS NOT NULL').order('priority DESC')
      initial_app_roles.each { |initial_app_role|
        result = /#{initial_app_role.email_pattern}/ =~ email
        if result.nil?
        else
          app_role = initial_app_role.app_role
          break
        end
      }
    else
      app_role = initial_app_role.app_role
    end

    app_role
  end

  def as_json(options={})
    {
        :id => self.id,
        :description => self.description,
        :email => self.email,
        :email_pattern => self.email_pattern,
        :app_role => self.app_role,
        :priority => self.priority,
        :enabled => self.enabled,
        :created_at => self.created_at,
        :updated_at => self.updated_at
    }
  end

end
