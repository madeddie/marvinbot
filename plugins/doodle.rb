require_relative 'lib/doodle_poll'

# Create instance of DoodlePoll class and execute command
class Doodle
  include Cinch::Plugin

  match(/doodle(.*)/)

  def execute(msg, query)
    cmd, url = query.split if query
    cmd ||= 'winner'
    url ||= msg.channel.topic[%r{http://doodle.com/poll/.\w+}]
    if cmd == 'help'
      cmds = DoodlePoll.help
      msg.reply("Available commands: #{cmds}")
    elsif url
      debug "Trying to parse #{url} and respond to command #{cmd}"
      doodle = DoodlePoll.new(url)
      if doodle.respond_to? cmd
        msg.reply(doodle.send(cmd))
      else
        msg.reply("Unknown command: #{cmd}")
      end
    else
      msg.reply('No url found, use ~doodle <cmd> <url> to supply url')
    end
  end
end
