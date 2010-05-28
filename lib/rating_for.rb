module ActiveRecord
  module RatingFor

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def rating_for(element, options = {})
        has_one "rating_for_#{element}", 
                :dependent => :destroy, 
                :as => :element,
                :conditions => {:element_attribute => element.to_s}
        
        define_method "rating_for_#{element}" do
          rateable_element = instance_variable_get("@_rating_for_#{element}")
          
          if rateable_element.nil?
            rateable_element = RateableElement.find_by_element_id(self.id, :conditions => {:element_type => self.class.name, :element_attribute => element.to_s})
            rateable_element = RateableElement.new(:element_id => self.id, :element_type => self.class.name, :element_attribute => element.to_s) if rateable_element.nil?
            instance_variable_set("@_rating_for_#{element}", rateable_element)
          end
          
          rateable_element
        end

        (class << self; self; end).module_eval do
          define_method "find_where_#{element}_has_average_rating_of" do |value|
            self.find_with_average_rating_of(element.to_s, value)
          end
        end
        
        (class << self; self; end).module_eval do
          define_method "find_where_#{element}_has_total_rating_of" do |value|
            self.find_with_average_rating_of(element.to_s, value)
          end
        end
        
        (class << self; self; end).module_eval do
          define_method "find_where_#{element}_has_ratings_count_of" do |value|
            self.find_with_average_rating_of(element.to_s, value)
          end
        end        
        
        (class << self; self; end).module_eval do
          define_method "find_where_#{element}_was_rated_by" do |rater|
            self.find_rated_by(element.to_s, rater)
          end
        end
        
        extend ActiveRecord::RatingFor::SingletonMethods
      end
    end

    module SingletonMethods
      # TODO Check if this is DB-agnostic
      def find_with_average_rating_of(element, value)
        find :all, :conditions => "rateable_elements.element_attribute = \"#{element}\" AND rateable_elements.avg_rating = \"#{value}\"", 
             :joins => "INNER JOIN rateable_elements ON rateable_elements.element_id = #{self.name.underscore.pluralize}.id"
      end
      
      def find_with_total_rating_of(element, value)
        find :all, :conditions => "rateable_elements.element_attribute = \"#{element}\" AND rateable_elements.total_rating = \"#{value}\"", 
             :joins => "INNER JOIN rateable_elements ON rateable_elements.element_id = #{self.name.underscore.pluralize}.id"
      end
      
      def find_with_ratings_count_of(element, value)
        find :all, :conditions => "rateable_elements.element_attribute = \"#{element}\" AND rateable_elements.ratings_count = \"#{value}\"", 
             :joins => "INNER JOIN rateable_elements ON rateable_elements.element_id = #{self.name.underscore.pluralize}.id"
      end
      
      def find_rated_by(element, rater)
        found_objects = []
        Rating.find(:all, :conditions => "rater_id = #{rater.id} AND rater_type = \"#{rater.class}\" AND element_attribute = \"#{element}\"", :joins => [:rateable_element]).each do |rating|
          found_objects << find(:first, :conditions => {:id => rating.rateable_element.element_id})
        end
        found_objects.compact
      end      
    end

  end
end
