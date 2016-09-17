require 'singleton'
require 'rufus/scheduler'

class AppConfig
  include Singleton
  # To change this template use File | Settings | File Templates.

  attr_accessor :scheduler

  def self.instance
    @@instance ||= new
  end

  def initialize
    require 'net/http'
    require 'uri'
    @scheduler = Rufus::Scheduler.new()

    @scheduler.in '30s' do
      City.ping_all_cities()
    end

    @scheduler.cron '13 2 * * *' do
      # do something every day, at 02:13
      # (see "man 5 crontab" in your terminal)
        City.destroy_inactive_cities()
    end

=begin
    if false

      @scheduler.every '1h' do
        begin
          url = 'http://localhost:3000/cities/ping'
          Net::HTTP.get_response(URI.parse(url))
        rescue
          # do nothing
        end
        City.ping_all_cities()
      end

    end
=end

  end
end