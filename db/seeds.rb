# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


require File.expand_path('../seed/base', __FILE__) # all necessary for gameplay
require File.expand_path('../seed/initial_app_roles', __FILE__) # initial app roles
unless Rails.env.test? || Rails.env.production?
  require File.expand_path('../seed/city1', __FILE__) # example city
end
