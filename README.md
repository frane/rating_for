# rating_for

## A context-based rating plugin for Rails
This plugin allows you to add multiple different rating criteria to your ActiveRecord based model. It provides column-caching, a polymorphic association for raters and works with both Rails 2 and 3.

It's a pure model plugin and does not provide any view methods. Prototype, jQuery and company provide all excellent method an plugins for this.

## Installation
Rails 2:

    script/plugin install git://github.com/frane/rating_for.git
    script/generate rating_for_migration

Rails 3:
    
    rails plugin install git://github.com/frane/rating_for.git
    rails g rating_for_migration


## Example
Let's say you want to rate hotels by different criteria, like room service or quality.
Then your model hotel.rb should look like this:
    
    class Hotel < ActiveRecord::Base
      rating_for :room_service
      rating_for :quality
    end

You can add ratings like this:
  
    four_seasons = Hotel.find_by_name("Four Seasons")
    four_seasons.rating_for_quality.add(10)
    four_seasons.rating_for_room_service.add(9)
    
    rating = Rating.new(:value => 7)
    marriott = Hotel.find_by_name('Marriott')
    marriott.rating_for_room_service << rating
    
You can also assign raters to your ratings,
e.g. customers

    class Customer < ActiveRecord::Base
    end

or newspapers
    
    class Newspaper < ActiveRecord::Base
    end

by simply adding them to your rating:
  
    a_customer = Customer.find(1)
    nytimes = Newspaper.find_by_name("New York Times")
    
    four_seasons.rating_for_quality.add(10, a_customer)
    marriott.rating_for_room_service << Rating.new(:rater => nytimes, :value => 8)
    
Search over ratings is also possible:

    hotels = Hotel.find_where_quality_has_average_rating_of(10)
    
    hotel1 = hotels.first
    hotel1.name
    => "Four Seasons"
    hotel1.avg_rating
    => 10.0
    
## TODO
 * Add more (better) query methods
 * Add more examples

## License
Copyright (c) 2010 [Frane Bandov](http://github.com/frane), released under the MIT license
