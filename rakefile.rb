require 'travis'

token = ENV['GH_TOKEN']

# against the Travis namespace
Travis.github_auth(token)
puts "Hello #{Travis::User.current.name}!"
