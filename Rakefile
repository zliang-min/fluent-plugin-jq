require "bundler"
Bundler::GemHelper.install_tasks

require "rake/testtask"

task :build_example do
  sh 'docker build -t fluent-plugin-jq-example .'
end

task :rm_example do
  sh 'docker image rm fluent-plugin-jq-example'
end

task :run_example do
  sh 'docker run -it --rm fluent-plugin-jq-example'
end

Rake::TestTask.new(:test) do |t|
  t.libs.push("lib", "test")
  t.test_files = FileList["test/**/test_*.rb"]
  t.verbose = true
  t.warning = true
end

task default: [:test]
