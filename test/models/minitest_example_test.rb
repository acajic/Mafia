require 'test_helper'
require 'minitest/autorun'


class MinitestExampleTest < Minitest::Test

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup

    @city = create(:city)


  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown


    @city.destroy()
    User.destroy_all()

  end


  # Fake test
  def test_ok

    # To change this template use File | Settings | File Templates.
    assert true
  end
end