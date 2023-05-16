# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'pronto/doc8/version'

Gem::Specification.new do |s|
  s.name = 'pronto-doc8'
  s.version = Pronto::Doc8Version::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Nerijus Bendziunas']
  s.email = 'nerijus.bendziunas@gmail.com'
  s.homepage = 'https://github.com/benner/pronto-doc8'
  s.summary = <<-SUMMARY
    Pronto runner for doc8.
  SUMMARY

  s.licenses = ['Apache-2.0']
  s.required_ruby_version = '>= 3.1.0'

  s.files = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths = ['lib']
  s.requirements << 'doc8 (in PATH)'

  s.add_dependency('pronto', '< 12.0.0')
  s.add_development_dependency 'bundler', '~> 2.4.3'
  s.add_development_dependency('rake', '~> 12.0')
  s.add_development_dependency('rspec', '~> 3.4')
  s.metadata['rubygems_mfa_required'] = 'true'
end
