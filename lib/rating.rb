class Rating < ActiveRecord::Base
  belongs_to :rateable_element
  belongs_to :rater, :polymorphic => true

  validates_associated :rateable_element
  validates_presence_of :value
end