# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rating_for/version"

Gem::Specification.new do |s|
  s.name        = "rating_for"
  s.version     = RatingFor::VERSION
  s.authors     = ["Frane Bandov"]
  s.email       = ["frane.bandov@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A context-based rating gem for Rails}
  s.description = %q{This plugin allows you to add multiple different rating criteria to your ActiveRecord based model. It provides column-caching and a polymorphic association for raters.}

  s.rubyforge_project = "rating_for"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]


  s.add_dependency 'activerecord', '~> 3.0'
  s.add_development_dependency 'sqlite3'
end
