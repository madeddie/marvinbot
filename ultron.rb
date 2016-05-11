require 'cinch'
require 'yaml'

# plugins
require_relative 'plugins/identify'
require_relative 'plugins/hello'
require_relative 'plugins/version'
require_relative 'plugins/source'
require_relative 'plugins/doodle'
require_relative 'plugins/topic'
require_relative 'plugins/hoegaathetmet'

config = YAML.load(File.read('./config.yml'))

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = config['nickname']
    c.server = config['server']
    c.channels = config['channels']
    c.realname = 'I will survive, Hey Hey'
    c.user = 'ultron'
    c.plugins.prefix = /^~/
    c.plugins.plugins = [
      Cinch::Plugins::Identify,
      Hello, Version, Source,
      Doodle, Topic, HoeGaat
    ]
    c.plugins.options[Cinch::Plugins::Identify] = {
      username: config['username'],
      password: config['password'],
      type:     :nickserv
    }
  end

  trap 'SIGINT' do
    bot.quit
  end
end

bot.start
