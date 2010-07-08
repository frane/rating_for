class Rating < ActiveRecord::Base
  belongs_to :rateable_element
  belongs_to :rater, :polymorphic => true

  validates_associated :rateable_element
  validates_presence_of :value
  
  after_destroy :update_rateable_element
  after_update :update_rateable_element
  
  def rated_element
    self.rateable_element.element
  end
  
  def rating_for
    self.rateable_element.element_attribute
  end
  
  def rating_for?(element)
    element.to_s == self.rating_for
  end
  
  def is_for
    self.rating_for
  end
  
  def is_for?(element)
    self.rating_for?(element)
  end
  
  protected
  
  def update_rateable_element
    self.rateable_element.recalculate_rating
  end
  
end