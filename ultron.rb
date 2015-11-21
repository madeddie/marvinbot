require 'cinch'
require 'yaml'

# plugins
require_relative 'plugins/identify'
require_relative 'plugins/hello'
require_relative 'plugins/version'
require_relative 'plugins/source'
require_relative 'plugins/doodle'

config = YAML.load(File.read('./config.yml'))

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = 'ultron'
    c.server = 'irc.freenode.org'
    c.channels = ['##ultron', '#dehaarlemseconnectie']
    c.realname = 'I will survice, Hey Hey'
    c.user = 'ultron'
    c.plugins.prefix = /^~/
    c.plugins.plugins = [Identify, Hello, Version, Source]
    c.plugins.options[Identify] = {
      password: config['password'],
      type:     :nickserv
    }
  end

  trap 'SIGINT' do
    bot.quit
  end
end

bot.start
