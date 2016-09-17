class Day < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :city

  # attr_accessible :number, :city_id, :city

  def as_json(options={})
    {
        :id => self.id,
        :city_id => self.city_id,
        :city_name => self.city ? self.city.name : nil,
        :number => self.number,
        :created_at => self.created_at
    }
  end


end
