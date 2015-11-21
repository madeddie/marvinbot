class Topic
  include Cinch::Plugin

  match('topic')

  def execute(m)
    m.reply "#{m.user.nick}, channel is #{m.channel}, topic is #{m.channel.topic}"
  end
end
