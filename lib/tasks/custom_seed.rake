# lib/tasks/custom_seed.rake
namespace :db do
  namespace :seed do
    task :single => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seed', "#{ENV['SEED']}.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
  end
end