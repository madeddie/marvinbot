require 'cinch'

# plugins
require_relative "plugins/hello"

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "ultron"
    c.server = "irc.freenode.org"
    c.channels = ["##ultron", "#dehaarlemseconnectie"]
    c.realname = "The Paranoid Android"
    c.user = "ultron"
    c.plugins.prefix = /^~/
    c.plugins.plugins = [Hello]
  end

end

bot.start
