require_relative 'lib/hoegaathetmet'

# Create instance of DoodlePoll class and execute command
class HoeGaat
  include Cinch::Plugin

  match(/hoe (.*)/)

  def execute(msg, query)
    hoe = HoeGaatHetMet.new(query)
    msg.reply("#{hoe.name} is currently #{hoe.current}") if hoe
  rescue NoMethodError
    msg.reply("Nobody found with name: #{query}")
  end
end
