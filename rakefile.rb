require 'travis'

task :default do
end

# this should all work, but it doesnt seem to because logins have happend too much
# see https://github.com/travis-ci/travis.rb/issues/315
# login has worked a few times, then started failing

token = ENV['GH_TOKEN']
TRAVIS_BRANCH = ENV['TRAVIS_BRANCH']

# against the Travis namespace
Travis.github_auth(token)
puts "User: #{Travis::User.current.name}!"
puts "Branch: #{TRAVIS_BRANCH}!"


Travis::Repository.find('haxeui/haxeui-blank').branch("#{TRAVIS_BRANCH}").restart
Travis::Repository.find('haxeui/haxeui-openfl').branch("#{TRAVIS_BRANCH}").restart
Travis::Repository.find('haxeui/haxeui-html5').branch("#{TRAVIS_BRANCH}").restart
Travis::Repository.find('haxeui/haxeui-pixijs').branch("#{TRAVIS_BRANCH}").restart
Travis::Repository.find('haxeui/haxeui-nme').branch("#{TRAVIS_BRANCH}").restart
Travis::Repository.find('haxeui/haxeui-kha').branch("#{TRAVIS_BRANCH}").restart
Travis::Repository.find('haxeui/haxeui-hxwidgets').branch("#{TRAVIS_BRANCH}").restart
