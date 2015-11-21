require_relative 'lib/doodle'

# Create instance of DoodlePoll class and execute command
class Doodle
  include Cinch::Plugin

  match(/doodle(.*?)/)

  def execute(msg, query)
    if query
      query_parts = query.split
      cmd = query.parts[0]
      url = query.parts[1] if query_parts > 1
    end
    cmd = 'winner' unless cmd
    url = %r{http://doodle.com/polls/.+?}.match(msg.channel.topic)[0] unless url
    doodle = DoodlePoll.new(url)
    msg.reply doodle.send(cmd)
  end
end
