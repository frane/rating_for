require 'rails/generators'
require 'rails/generators/migration' 

module RatingFor
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc 'Generates a migration file that contains all tables that are needed by the rating_for gem'

    def self.source_root
      @source_root ||= File.expand_path('../templates', __FILE__)
    end
    
    def self.next_migration_number(path)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(path) + 1)
      end
    end

    def manifest
      migration_template 'migration.rb', 'db/migrate/create_rating_for_tables'
    end
  end
end
