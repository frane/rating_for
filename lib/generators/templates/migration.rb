class RatingForMigration < ActiveRecord::Migration
  def self.up
    create_table :rateable_elements do |t|
    	t.string  :element
    	t.integer :element_id
    	t.integer :avg_rating
    	t.integer :total_rating
    	t.integer :ratings_count
    	
      t.timestamps
    end
    
    create_table :ratings do |t|
      t.integer :value
      t.integer :rateable_element_id
      t.integer :user_id
      
      t.timestamps
    end
    
    add_index :ratings, :rateable_element_id
    add_index :ratings, :user_id
    add_index :rateable_elements, [:element, :element_id]
  end
  
  def self.down
    drop_table :ratings
    drop_table :rateable_elements
  end
end