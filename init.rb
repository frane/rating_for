require File.dirname(__FILE__) + '/lib/rating_for'
require File.dirname(__FILE__) + '/lib/rating'
require File.dirname(__FILE__) + '/lib/rateable_element'

ActiveRecord::Base.send(:include, ActiveRecord::RatingFor)