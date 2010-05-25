class Rating < ActiveRecord::Base
  belongs_to :rateable_element
  belongs_to :rater, :polymorphic => true

  #validates_presence_of :rateable_element_id
  #validates_presence_of :value
end