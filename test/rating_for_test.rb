require 'test_helper'

class User < ActiveRecord::Base
end

class Hotel < ActiveRecord::Base
end

class Newspaper < ActiveRecord::Base
end

class RatingForTest < ActiveRecord::TestCase  
  include ActiveRecord::TestFixtures

  self.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
  # self.fixture_table_names = ActiveRecord::Base.connection.tables
  self.use_transactional_fixtures = true
  fixtures :all


  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "simple" do
    user = User.find(1)
    assert_equal 1, user.id
  end
end
