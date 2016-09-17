class ResidentPreviousRole < ActiveRecord::Base
  belongs_to :resident, :inverse_of => :resident_previous_roles
  belongs_to :role, foreign_key: :previous_role_id
  belongs_to :day

  # attr_accessible :resident_id, :resident, :previous_role_id, :role, :day_id, :day
end
