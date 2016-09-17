class DayCycle < ActiveRecord::Base
  belongs_to :city

  # attr_accessible :day_start, :night_start

  def as_json(options={})
    {
        :id => self.id,
        :day_start => self.day_start,
        :night_start => self.night_start
    }
  end
end
