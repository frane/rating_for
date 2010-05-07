class RateableElement < ActiveRecord::Base
  has_many :ratings
  
  validates_uniqueness_of :element_id, :scope => [:element]
end