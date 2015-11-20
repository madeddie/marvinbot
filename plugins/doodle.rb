require_relative 'lib/doodle'

class Doodle
  include Cinch::Plugin

  match(/doodle (.*)/)

  def execute(msg, text)
    if text
      url = text
    else
      url = msg.channel.topic
    end
    doodle = DoodlePoll.new(url)
    msg.reply doodle.winner
  end
end
