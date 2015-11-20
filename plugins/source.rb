class Source
  include Cinch::Plugin

  match "source"

  def execute(m)
    m.reply "#{m.user.nick}, find my code on: https://github.com/madeddie/ultronbot"
  end
end
