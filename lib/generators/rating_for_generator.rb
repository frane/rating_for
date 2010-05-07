require 'rails/generators/migration'

class RatingForGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  
  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end
  
  def self.next_migration_number(path)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/create_rating_for_tables' 
  end
end
