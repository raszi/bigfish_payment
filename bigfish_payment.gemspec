# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bigfish_payment/version"

Gem::Specification.new do |s|
  s.name        = "bigfish_payment"
  s.version     = BigfishPayment::VERSION
  s.authors     = ["KARASZI István"]
  s.email       = ["github@spam.raszi.hu"]
  s.homepage    = "http://raszi.hu/"
  s.summary     = %q{BigFish Payment Gateway Client for Rails}
  s.description = %q{This is a Rails plugin to communicate with BigFish Payment Gateway}

  s.rubyforge_project = "bigfish_payment"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "httpclient", "~> 2.2.1"
end
