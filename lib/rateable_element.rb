class RateableElement < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
  belongs_to :element, :polymorphic => true
  
  validates_uniqueness_of :element_id, :scope => [:element_type, :element_attribute]
  
  def <<(rating)
    self.add_rating(rating)
  end
  
  def add_rating(rating)
    return self.ratings unless rating.is_a?(Rating)
    self.ratings << rating
    self.total_rating += rating.value
    self.ratings_count += 1
    self.avg_rating = self.total_rating / self.ratings_count
    self.save
  end
  
  def add(value, rater = nil)
    self.add_rating(Rating.new(:rater => rater, :value => value))
  end
  
  def remove_rating(rating)
    return self.ratings unless rating.is_a?(Rating)
    self.total_rating -= rating.value
    self.ratings_count -= 1
    self.avg_rating = self.total_rating / self.ratings_count
    rating.destroy
  end
  
  def remove_by_rater(rater)
    rating = self.ratings.find_by_rater(rater)
    self.remove_rating(rating)
  end
  
  def clear
    self.ratings = []
    self.recalculate_rating
  end
  
  def delete_all
    self.clear
  end
  
  def rated_by?(rater)
    not self.ratings.find_all_by_rater_id(rater.id, :conditions => {:rater_type => rater.class.name}).empty?
  end
  
  def recalculate_rating
    self.total_rating = 0
    self.ratings_count = 0
    self.avg_rating = 0
    self.ratings.each do |r|
      self.total_rating += self.rating.value
      self.ratings_count += 1 
    end
    self.avg_rating = self.total_rating / self.ratings_count
    self.save
  end
end