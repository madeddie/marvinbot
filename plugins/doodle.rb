require_relative 'lib/doodle'

# Create instance of DoodlePoll class and execute command
class Doodle
  include Cinch::Plugin

  match(/doodle(.*)/)

  def execute(msg, query)
    if query
      query_parts = query.split
      cmd = query_parts[0]
      url = query_parts[1] if query_parts.count > 1
    end
    cmd = 'winner' unless cmd
    url = %r{http://doodle.com/polls/.\w+}.match(msg.channel.topic)[0] unless url
    doodle = DoodlePoll.new(url)
    msg.reply doodle.send(cmd)
  end
end
