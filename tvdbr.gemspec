# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tvdbr/version"

Gem::Specification.new do |s|
  s.name        = "tvdbr"
  s.version     = Tvdbr::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Miso", "Nathan Esquenazi"]
  s.email       = ["nesquena@gmail.com"]
  s.homepage    = "https://github.com/bazaarlabs/tvdbr"
  s.summary     = %q{Use the TVDB API from Ruby}
  s.description = %q{Utilize the TVDB API from Ruby to fetch shows, track updates to the tvdb and sync your media database}
  s.rubyforge_project = "tvdbr"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "hashie"
  s.add_dependency "httparty", '>= 0.8.0'
  s.add_development_dependency "rake"
end
