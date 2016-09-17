class Trigger < ActiveRecord::Base
  # attr_accessible :name, :description

  NIGHT_START = 1
  DAY_START = 2
  BOTH = 3
  ASYNC = 4
  NO_TRIGGER = 5

  def as_json(options={})
    {
        :id => self.id,
        :name => self.name,
        :description => self.description
    }
  end

end
