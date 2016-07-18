require 'travis'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new
task :default => :spec

token = ENV['GH_TOKEN']

# against the Travis namespace
Travis.github_auth(token)
puts "Using #{Travis::User.current.name}!"
