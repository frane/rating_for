require_relative 'test_helper.rb'

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
    # init
    hotel = Hotel.find(1)
    user = User.find(1)
    user2 = User.find(2)
    newspaper = Newspaper.find(1)

    # everything OK?
    assert hotel.rating_for_quality
    assert hotel.rating_for_service
    assert newspaper.rating_for_reputation

    # add a rating object
    r = Rating.new(:rater => user, :value => 2)
    hotel.rating_for_quality << r
    assert_equal hotel.rating_for_quality.avg_rating, hotel.rating_for_quality.total_rating
    assert_equal r.rated_element, hotel
    assert_equal r.rating_for, "quality"
    assert r.rating_for?(:quality) 
    
    # add a rating by value - preferred way 
    hotel.rating_for_quality.add(10, user2)
    assert_equal hotel.rating_for_quality.avg_rating, 6

    hotel.rating_for_quality.add(10)
    assert_equal hotel.rating_for_quality.avg_rating.round, 7

    assert_equal hotel.rating_for_quality.ratings_count, 3
    assert hotel.rating_for_quality.rated_by?(user2)
    
    # find by rating
    hotel.rating_for_service.add(10, user)
    assert_equal Hotel.find_where_service_has_average_rating_of(10).first, hotel

    assert hotel.rating_for_service.rated_by?(user)
    assert_equal hotel.rating_for_service.rated_by?(newspaper), false
  end

  test "remove ratings" do
    # init
    hotel = Hotel.find(1)
    user = User.find(1)
    
    hotel.rating_for_quality.add(10)
    hotel.rating_for_quality.add(5)
    hotel.rating_for_quality.add(7)
    hotel.rating_for_quality.add(2, user)
    hotel.rating_for_quality.add(1)
    
    hotel.rating_for_service.add(10)
    
    avg_rating = hotel.rating_for_quality.avg_rating
    
    # everything OK?
    h = Hotel.find_where_quality_has_average_rating_of(avg_rating).first
    assert_equal hotel.rating_for_quality.avg_rating, h.rating_for_quality.avg_rating
    assert_equal hotel.id, h.id
    
    r = Rating.find(1)
    assert_equal 10, r.value
    
    # remove a rating object by calling its destroy method - not recommended
    r.destroy
    new_avg_rating = (5 + 7 + 2 + 1).to_f / 4
    assert new_avg_rating != avg_rating
    assert new_avg_rating != h.rating_for_quality.avg_rating
    assert_equal avg_rating, h.rating_for_quality.avg_rating
    
    # the reference to the rating object is kept until the referring object is reloaded
    h.rating_for_quality.reload
    assert avg_rating != h.rating_for_quality.avg_rating
    assert_equal new_avg_rating, h.rating_for_quality.avg_rating
    
    assert hotel.rating_for_quality.avg_rating != new_avg_rating
    assert_equal avg_rating, hotel.rating_for_quality.avg_rating
    
    # new objects get their data fresh out of the database - this data is correct
    h2 = Hotel.find(1)
    assert_equal h.rating_for_quality.avg_rating, h2.rating_for_quality.avg_rating
    assert hotel.rating_for_quality.avg_rating != h2.rating_for_quality.avg_rating
    assert_equal new_avg_rating, h2.rating_for_quality.avg_rating
    
    # instead of reloading we can racalculate without the destroyed object - not recommended
    hotel.rating_for_quality.recalculate_rating_without(r)
    assert hotel.rating_for_quality.avg_rating != avg_rating
    assert_equal new_avg_rating, hotel.rating_for_quality.avg_rating
    
    # preferred way: delete ratings through remove_rating
    avg_rating = hotel.rating_for_quality.avg_rating
    new_avg_rating = (7 + 2 + 1).to_r / 3
    r = Rating.find(2)
    
    hotel.rating_for_quality.remove_rating(r)
    assert avg_rating != hotel.rating_for_quality.avg_rating
    assert_equal new_avg_rating, hotel.rating_for_quality.avg_rating
    
    # or through remove_by_rater
    avg_rating = hotel.rating_for_quality.avg_rating
    new_avg_rating = (7 + 1).to_r / 2
    hotel.rating_for_quality.remove_by_rater user
    assert avg_rating != hotel.rating_for_quality.avg_rating
    assert_equal new_avg_rating, hotel.rating_for_quality.avg_rating
  end

  test "remove objects" do
    hotel = Hotel.find(1)
    hotel.rating_for_service.add 10

    r = RateableElement.where(:element_type => 'Hotel', :element_attribute => 'service', :element_id => 1)
    assert_equal 1, r.count

    hotel.destroy
    r = RateableElement.where(:element_type => 'Hotel', :element_attribute => 'service', :element_id => 1)
    assert_equal 0, r.count
  end
end
