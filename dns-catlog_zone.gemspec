# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dns/catlog_zone/version'

Gem::Specification.new do |spec|
  spec.name          = 'dns-catlog_zone'
  spec.version       = Dns::CatlogZone::VERSION
  spec.authors       = ['Manabu Sonoda']
  spec.email         = ['mimuret@gmail.com']

  spec.summary       = 'create zone config from catlog zone file.'
  spec.description   = 'create zone config from catlog zone file.'
  spec.homepage      = 'https://github.com/mimuret/dns-catlog_zone'
  spec.license       = 'MIT'

  spec.cert_chain    = ['certs/mimuret.pem']
  spec.signing_key   = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME.end_with?('gem')
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_runtime_dependency 'dnsruby', '>= 1.60.1'
  spec.add_runtime_dependency 'thor', '~> 0'
  spec.add_runtime_dependency 'camelizable', '~> 0'
end
