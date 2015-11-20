require 'cinch'

# plugins
require_relative "plugins/hello"
require_relative "plugins/version"

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "ultron"
    c.server = "irc.freenode.org"
    c.channels = ["##ultron", "#dehaarlemseconnectie"]
    c.realname = "I will survice, Hey Hey"
    c.user = "ultron"
    c.plugins.prefix = /^~/
    c.plugins.plugins = [Hello, Version]
  end

end

bot.start
