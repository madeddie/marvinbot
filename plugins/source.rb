# Print the current url of the repo where this code resides
class Source
  include Cinch::Plugin

  match 'source'

  def execute(m)
    m.reply "#{m.user.nick}, my soure: https://github.com/madeddie/ultronbot"
  end
end
