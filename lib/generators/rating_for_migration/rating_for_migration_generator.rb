IS_RAILS_2 = Rails.version.to_f < 3

unless IS_RAILS_2
  require 'rails/generators/migration' 
  generator_parant = Rails::Generators::Base
else
  generator_parant = Rails::Generator::Base
end

class RatingForMigrationGenerator < generator_parant
  include Rails::Generators::Migration unless IS_RAILS_2

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
    unless IS_RAILS_2
      migration_template 'migration.rb', 'db/migrate/create_rating_for_tables'
    else
      record do |m|
        m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "create_rating_for_tables"
      end
    end
  end
end
