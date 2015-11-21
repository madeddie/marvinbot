# A simple plugin to test if the bot is awake and functioning
class Hello
  include Cinch::Plugin

  match 'hello'

  def execute(m)
    m.reply "Hello, #{m.user.nick}"
  end
end
