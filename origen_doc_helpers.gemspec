# coding: utf-8
config = File.expand_path('../config', __FILE__)
require "#{config}/version"

Gem::Specification.new do |spec|
  spec.name          = "origen_doc_helpers"
  spec.version       = OrigenDocHelpers::VERSION
  spec.authors       = ["Stephen McGinty"]
  spec.email         = ["stephen.f.mcginty@gmail.com"]
  spec.summary       = "Snippets and helpers for creating Origen web documents"
  spec.homepage      = "http://origen-sdk.org/doc_helpers"
  spec.license       = 'LGPL-3'
  spec.required_ruby_version     = '>= 1.9.3'
  spec.required_rubygems_version = '>= 1.8.11'

  # Only the files that are hit by these wildcards will be included in the
  # packaged gem, the default should hit everything in most cases but this will
  # need to be added to if you have any custom directories
  spec.files         = Dir["lib/**/*.rb", "templates/**/*", "config/**/*.rb",
                           "bin/*", "lib/tasks/**/*.rake", "pattern/**/*.rb",
                           "program/**/*.rb"
                          ]
  spec.executables   = []
  spec.require_paths = ["lib"]

  # Add any gems that your plugin needs to run within a host application
  spec.add_runtime_dependency "origen", ">= 0.0.5"

  # Add any gems that your plugin needs for its development environment only
  #spec.add_development_dependency "origen_doc_helpers", ">= 0.1.0"
end
