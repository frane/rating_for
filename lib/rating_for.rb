module ActiveRecord
  module RatingFor

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def rating_for(element, options = {})
        has_one :rateable_element, 
        :foreign_key => :element_id, 
        :dependent => :destroy, 
        :as => "rating_for_#{element.to_s}", 
        :conditions => ["element = ?", "#{self.name}.#{element}"]

        include ActiveRecord::RatingFor::InstanceMethods
        extend ActiveRecord::RatingFor::SingletonMethods
      end
    end

    module SingletonMethods
      # Find all objects rated by score.
      def find_average_rating_for(element, value)
        find(:all, :conditions => ["element = ? AND avg_rating", "#{self.name}.#{element}", value])
      end
    end

    module InstanceMethods
      # Rates the object by a given score. A user object can be passed to the method.
      def rate_it( score, user_id )
        return unless score
        rate = Rate.find_or_create_by_score( score.to_i )
        rate.user_id = user_id
        rates << rate
      end

      # Calculates the average rating. Calculation based on the already given scores.
      def average_rating
        return 0 if rates.empty?
        ( rates.inject(0){|total, rate| total += rate.score }.to_f / rates.size )
      end

      # Rounds the average rating value.
      def average_rating_round
        average_rating.round
      end

      # Returns the average rating in percent. The maximal score must be provided	or the default value (5) will be used.
      # TODO make maximum_rating automatically calculated.
      def average_rating_percent( maximum_rating = 5 )
        f = 100 / maximum_rating.to_f
        average_rating * f
      end

      # Checks wheter a user rated the object or not.
      def rated_by?( user )
        ratings.detect {|r| r.user_id == user.id }
      end
    end

  end
end
