require File.join(File.expand_path(File.dirname(__FILE__)), "random_bot")

class RandomBotSwarm
  def initialize(uri, bot_prefix="randbot", size = 10)
    @bot_prefix = bot_prefix
    @size = size
    @client = Chat::Client.new uri
    @bots = []
    (1..@size).each do |i|
      bot_name = "#{bot_prefix}#{i}"
      resp = @client.register_user(bot_name)
      if resp.status == :OK
        @bots << RandomBot.new(uri, resp.session_id)
      end
    end
  end

  def run
    if @threads.nil?
      @threads = @bots.map do |bot|
        Thread.new {bot.run}
      end
      @threads.each{|t| t.join}
    end
  end
end
