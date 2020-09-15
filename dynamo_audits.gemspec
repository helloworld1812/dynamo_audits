require_relative 'lib/dynamo_audits/version'

Gem::Specification.new do |spec|
  spec.name          = "dynamo_audits"
  spec.version       = DynamoAudits::VERSION
  spec.authors       = ["Ryan Lv"]
  spec.email         = ["ryan@workstream.is"]

  spec.summary       = %q{Track activerecord changes to dynamodb}
  spec.description   = spec.summary  
  spec.homepage      = "https://github.com/helloworld1812/dynamo_audits"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/helloworld1812/dynamo_audits"
  spec.metadata["changelog_uri"] = "https://github.com/helloworld1812/dynamo_audits"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependency
  spec.add_runtime_dependency 'activerecord', '>= 4.2'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'rails'
  spec.add_runtime_dependency 'aws-sdk'


  # Development dependency
  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3'
end
