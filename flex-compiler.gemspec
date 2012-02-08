# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "flex-compiler/version"

Gem::Specification.new do |s|
  s.name        = "flex-compiler"
  s.version     = FlexCompiler::VERSION
  s.authors     = ["ed eustace"]
  s.email       = ["ed.eustace@gmail.com"]
  s.homepage    = "http://github.com/edeustace/flex-compiler"
  s.summary     = "A simple api for using flex sdk command line tools"
  s.description = "Generates compc and mxmlc commands using sensible defaults - allowing only the user to only pass in a minimum number of arguments"

  s.rubyforge_project = "flex-compiler"

  s.files         = Dir.glob("lib/**/*.rb")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency "thor"
  s.add_development_dependency "rspec", "~> 2.6"
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
