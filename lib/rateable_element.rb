class RateableElement < ActiveRecord::Base
  has_many :ratings
  belongs_to :element, :polymorphic => true
  
  validates_uniqueness_of :element_id, :scope => [:element]
end