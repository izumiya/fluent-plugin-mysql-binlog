# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-mysql-binlog"
  spec.version       = "0.0.2"
  spec.authors       = ["IZUMIYA Hiroyuki"]
  spec.email         = ["izumiya@gmail.com"]
  spec.description   = %q{MySQL Binlog input plugin for Fluentd event collector.}
  spec.summary       = %q{MySQL Binlog input plugin for Fluentd event collector.}
  spec.homepage      = "https://github.com/izumiya/fluent-plugin-mysql-binlog"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "kodama"
  spec.add_runtime_dependency "activesupport"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
