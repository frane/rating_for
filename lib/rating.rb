class Rating < ActiveRecord::Base
  belongs_to :rateable_element
  
  validates_presence_of :rater_id
  validates_presence_of :rater_type
  validates_presence_of :rateable_element_id
  validates_presence_of :value
  
  validates_uniqueness_of :rater_id, :scope => [:rateable_element_id, :rater_type]
end