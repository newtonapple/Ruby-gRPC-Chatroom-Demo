require_relative "random_bot"

class RandomBotSwarm
  def initialize(uri, bot_prefix="randbot", size = 10)
    @bot_prefix = bot_prefix
    @size = size
    @uri = uri
    @client = Chat::Client.new uri
    @session_ids = []
    (1..@size).each do |i|
      bot_name = "#{bot_prefix}#{i}"
      resp = @client.register_user(bot_name)
      if resp.status == :OK
        @session_ids << resp.session_id
      end
    end
  end

  def run(single_client=true)
    if @threads.nil?
      @threads = if single_client
        @session_ids.map do |session_id|
          # we are reusing the same client
          Thread.new { RandomBot.run(@client, session_id) }
        end
      else
        @session_ids.map do |session_id|
          # each bot will create a new client connection
          bot = RandomBot.new(@uri, session_id)
          Thread.new { bot.run }
        end
      end
      @threads.each{|t| t.join}
    end
  end
end
