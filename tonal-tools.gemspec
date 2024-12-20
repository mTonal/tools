require "date"
require_relative "lib/tonal/attributions"

Gem::Specification.new do |spec|
  spec.name        = "tonal-tools"
  spec.version     = Tonal::TOOLS_VERSION
  spec.summary     = "Tonal tools"
  spec.description = "Basic tools, utilities and conveniences for microtonal music making and analysis"
  spec.authors     = ["Jose Hales-Garcia"]
  spec.email       = "jose@halesgarcia.com"
  spec.homepage    = "https://mtonal.github.io/tools/"
  spec.metadata = {
    "source_code_uri" => "https://github.com/mTonal/tools/",
    "documentation_uri" => "https://mtonal.github.io/tools/",
  }
  spec.license     = "MIT"
  spec.date        = Date.today.to_s
  spec.files       = Dir.glob(["lib/**/*", "data/**/*"])
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1")
  spec.required_rubygems_version = Gem::Requirement.new(">= 3.1")
  spec.rubygems_version = "3.5.23"
  spec.add_runtime_dependency "yaml", ["~> 0.4"]
  spec.add_runtime_dependency "json", ["~> 2.9"]
  spec.add_runtime_dependency "prime", ["~> 0.1"]
  spec.add_runtime_dependency "matrix", ["~> 0.4"]
  spec.add_runtime_dependency "sorted_set", ["~> 1.0"]
  spec.add_runtime_dependency "continued_fractions", ["~> 2.1"]
  spec.add_runtime_dependency "fraction-tree", ["~> 2.1"]
  spec.add_development_dependency "rspec", ["~> 3"]
  spec.add_development_dependency "byebug", ["~> 11.1"]
  spec.add_development_dependency "yard", ["~> 0.9"]
end
