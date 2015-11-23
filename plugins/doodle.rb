require_relative 'lib/doodle_poll'

# Create instance of DoodlePoll class and execute command
class Doodle
  include Cinch::Plugin

  match(/doodle(.*)/)

  def execute(msg, query)
    cmd, url = query.split if query
    cmd ||= 'winner'
    url ||= msg.channel.topic[%r{http://doodle.com/poll/.\w+}]
    if url
      doodle = DoodlePoll.new(url)
      msg.reply(doodle.send(cmd)) if doodle.respond_to? cmd
    else
      msg.reply('No url found, use ~doodle [cmd] [url] to supply url')
    end
  end
end
