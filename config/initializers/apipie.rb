require('apipie_validators')

Apipie.configure do |config|
  config.app_name                = 'Mafia'
  config.app_info                = 'The entire API is hosted on
  http://exposemafia.com:3000
'
  config.api_base_url            = ''
  config.doc_base_url            = '/apipie'
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"

  config.validate                = :explicitly
end

