lib = File.expand_path('../lib', __FILE__)

Gem::Specification.new do |spec|
  spec.name        = "tonal-tools"
  spec.version     = "0.1.1"
  spec.summary     = "Tonal tools"
  spec.description = "Basic tools, utilities and conveniences for microtonal music making and analysis"
  spec.authors     = ["Jose Hales-Garcia"]
  spec.email       = "jose@halesgarcia.com"
  spec.homepage    = "https://mtonal.github.io/tools/"
  spec.metadata = {
    "source_code_uri" => "https://github.com/mTonal/tools"
  }
  spec.files       = Dir.glob("lib/**/*")
  spec.add_runtime_dependency "prime", ["~> 0.1"]
  spec.add_runtime_dependency "matrix", ["~> 0.4"]
  spec.add_runtime_dependency "sorted_set", ["~> 1.0"]
  spec.add_runtime_dependency "continued_fractions", ["~> 1.8"]
  spec.add_runtime_dependency "fraction-tree", ["~> 0.1"]
  spec.add_development_dependency "rspec", ["~> 3.2"]
  spec.add_development_dependency "byebug", ["~> 11.1"]
  spec.add_development_dependency "yard", ["~> 0.9"]
  spec.license     = "MIT"
end
