class RateableElement < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
  belongs_to :element, :polymorphic => true
  
  validates_uniqueness_of :element_id, :scope => [:element_type, :element_attribute]
  validates_associated :element
  validates_presence_of :element_attribute
  
  def average_rating
    self.avg_rating
  end
  
  def averge_rating=(value)
    self.avg_rating = value
  end
  
  def <<(rating)
    self.add_rating(rating)
  end
  
  def add_rating(rating)
    return self.ratings unless rating.is_a?(Rating)
    self.ratings << rating
    self.total_rating += rating.value
    self.ratings_count += 1
    self.avg_rating = self.total_rating.to_f / self.ratings_count
    self.save
  end
  
  def add(value, rater = nil)
    self.add_rating(Rating.new(:rater => rater, :value => value))
  end
  
  def remove_rating(rating)
    return self.ratings unless rating.is_a?(Rating)
    self.total_rating -= rating.value
    self.ratings_count -= 1
    self.avg_rating = self.total_rating.to_f / self.ratings_count
    rating.destroy 
    self.save
  end
  
  def remove_by_rater(rater)
    self.ratings.find_all_by_rater_id(rater.id, :conditions => {:rater_type => rater.class.name}).each do |rating|
      self.remove_rating(rating)
    end
  end
  
  def clear
    self.ratings = []
    self.recalculate_rating
  end
  
  def remove_all
    self.clear
  end
  
  def rated_by?(rater)
    not self.ratings.find_all_by_rater_id(rater.id, :conditions => {:rater_type => rater.class.name}).empty?
  end
  
  def recalculate_rating
    self.recalculate_rating_without([])
  end
  
  def recalculate_rating_without(ratings)
    return unless (ratings.is_a? Rating or ratings.is_a? Array)

    self.total_rating = 0
    self.ratings_count = 0
    self.avg_rating = 0
    ratings = self.ratings - [ratings].compact.flatten
    ratings.each do |r|
      self.total_rating += r.value
      self.ratings_count += 1 
    end
    self.avg_rating = self.total_rating.to_f / self.ratings_count
    self.save
  end
end