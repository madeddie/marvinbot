# Output the version of Cinch framework to the user/channel
class Version
  include Cinch::Plugin

  match(/ver(sion)?/)

  def execute(m)
    m.reply "#{m.user.nick}, I'm running version #{Cinch::VERSION}"
  end
end
