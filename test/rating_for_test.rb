require 'test_helper'

class User < ActiveRecord::Base
end

class Hotel < ActiveRecord::Base
  rating_for :service
  rating_for :quality
end

class Newspaper < ActiveRecord::Base
  rating_for :reputation
end


class RatingForTest < ActiveRecord::TestCase  
  include ActiveRecord::TestFixtures

  self.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
  #self.fixture_table_names = ActiveRecord::Base.connection.tables
  self.use_transactional_fixtures = true
  fixtures :users, :hotels, :newspapers
  
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  
  test "add ratings" do
    hotel = Hotel.find(1)
    user = User.find(1)
    newspaper = Newspaper.find(1)
    
    assert hotel.rating_for_quality
    assert hotel.rating_for_service
    assert newspaper.rating_for_reputation
    
    r = Rating.new(:rater => user, :value => 2)
    hotel.rating_for_quality << r
    assert_equal hotel.rating_for_quality.avg_rating, hotel.rating_for_quality.total_rating
    
    hotel.rating_for_service.add(10, user)
    assert_equal Hotel.find_for_service_with_average_rating_of(10).first, hotel
    
    assert hotel.rating_for_service.rated_by?(user)
    assert_equal hotel.rating_for_service.rated_by?(newspaper), false
  end
  
  test "remove ratings" do
    
  end
end
