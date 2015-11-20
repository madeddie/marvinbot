class Version
  include Cinch::Plugin

  match /ver(sion)?/

  def execute(m)
    m.reply "#{m.user.nick}, I'm running version #{Cinch::VERSION}"
  end
end
