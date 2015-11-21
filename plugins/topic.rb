# Simple plugin to test functioning of the bot and topic awareness
# which might fail during or after a split
class Topic
  include Cinch::Plugin

  match('topic')

  def execute(m)
    channel = m.channel
    m.reply "#{m.user.nick}, channel is #{channel}, topic is #{channel.topic}"
  end
end
