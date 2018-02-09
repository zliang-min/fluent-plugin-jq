lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-jq"
  spec.version = "0.1.0"
  spec.authors = ["Zhimin (Gimi) Liang"]
  spec.email   = ["liang.gimi@gmail.com"]

  spec.summary       = %q{Fluentd formatter plugin uses the jq engine.}
  spec.description   = %q{A Fluentd formatter plugin allows you to format events using jq filters.}
  spec.homepage      = "https://github.com/Gimi/fluent-plugin-jq"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = Dir.glob('*').select { |f| not (File.directory?(f) || f.start_with?('.')) } +
    Dir.glob('lib/**/**.rb')
  spec.test_files    = Dir.glob('test/**/**.rb')
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_runtime_dependency "ruby-jq", "~> 0.1"
end
