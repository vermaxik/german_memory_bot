require 'rubygems'
require 'bundler/setup'

require 'mysql2'
require 'active_record'
require 'yaml'

namespace :db do
  desc 'Migrate the database'
  task :migrate do
    connection_details = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Migrator.migrate('db/migrate/')
  end

  desc 'Create the database'
  task :create do
    connection_details = YAML.load_file("config/database.yml")
    admin_connection = connection_details.merge({ 'database'=> 'mysql' })
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.create_database(connection_details["database"])
  end

  desc 'Drop the database'
  task :drop do
    connection_details = YAML.load_file('config/database.yml')
    admin_connection = connection_details.merge({ 'database'=> 'mysql' })
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.drop_database(connection_details["database"])
  end
end
