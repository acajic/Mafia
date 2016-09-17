require 'test_helper'


class CityTest < ActiveSupport::TestCase

  def test_city_start
    city = create(:city)

    city.start()

    assert(!city.started_at.nil?, 'City not started.')

    scheduler = AppConfig.instance.scheduler
    jobs = scheduler.jobs(:tag => city.scheduler_tag)

    assert(jobs.count == 2*city.day_cycles.count, 'There should be exactly 2 scheduler jobs per city day cycle.')

  end

end