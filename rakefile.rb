require 'travis'

task :default do
end

# this should all work, but it doesnt seem to because logins have happend too much
# see https://github.com/travis-ci/travis.rb/issues/315
# login has worked a few times, then started failing

token = ENV['GH_TOKEN']

# against the Travis namespace
Travis.github_auth(token)
puts "Using #{Travis::User.current.name}!"


Travis::Repository.find('haxeui/haxeui-blank').last_build.restart
Travis::Repository.find('haxeui/haxeui-openfl').last_build.restart
Travis::Repository.find('haxeui/haxeui-html5').last_build.restart
Travis::Repository.find('haxeui/haxeui-pixijs').last_build.restart
Travis::Repository.find('haxeui/haxeui-flambe').last_build.restart
Travis::Repository.find('haxeui/haxeui-nme').last_build.restart
Travis::Repository.find('haxeui/haxeui-kha').last_build.restart
Travis::Repository.find('haxeui/haxeui-luxe').last_build.restart
Travis::Repository.find('haxeui/haxeui-hxwidgets').last_build.restart
Travis::Repository.find('haxeui/haxeui-xwt').last_build.restart
