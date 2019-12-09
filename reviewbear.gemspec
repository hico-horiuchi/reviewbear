lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reviewbear/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'jira-ruby'
  spec.add_dependency 'octokit'
  spec.add_dependency 'rumale'
  spec.add_dependency 'settingslogic'
  spec.add_dependency 'thor'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.authors       = ['Akihiko Horiuchi']
  spec.bindir        = 'exe'
  spec.description   = 'Work in progress'
  spec.email         = %w(12ff5b8@gmail.com)
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.files         = %w(thor.gemspec) + Dir['*.md', 'bin/*', 'exe/*', 'lib/**/*.rb']
  spec.homepage      = 'https://github.com/hico-horiuchi/reviewbear'
  spec.licenses      = %w(MIT)
  spec.name          = 'reviewbear'
  spec.require_paths = ['lib']
  spec.summary       = spec.description
  spec.version       = Reviewbear::VERSION
end
