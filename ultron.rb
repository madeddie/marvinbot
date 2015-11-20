require 'cinch'

# plugins
require_relative "plugins/hello"
require_relative "plugins/version"
require_relative "plugins/source"
require_relative "plugins/doodle"

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "ultron"
    c.server = "irc.freenode.org"
    c.channels = ["##ultron", "#dehaarlemseconnectie"]
    c.realname = "I will survice, Hey Hey"
    c.user = "ultron"
    c.plugins.prefix = /^~/
    c.plugins.plugins = [Hello, Version, Source]
  end

  trap "SIGINT" do
    bot.quit
  end
end

bot.start
