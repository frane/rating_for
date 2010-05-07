class Rating < ActiveRecord::Base
  belongs_to :rateable_element
  
  validates_uniqueness_of :user_id, :scope => [:rateable_element_id]
end