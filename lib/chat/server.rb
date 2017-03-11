require 'grpc'
require 'protos/chat_services_pb'
require 'set'
require 'securerandom'
require 'thread'

module Chat
  class Server < Room::Service
    def initialize
      @session_ids = {}  # session_id to user_name mapping
      @user_names  = Set.new
      @message_queue  = Queue.new
      @delivery_queues = Set.new
      # receiver_message = ReceiverMessage.new(
      #   uuid: sender_message.uuid,
      #   user_name: user_name,
      #   text: sender_message.text
      #   timestamp: Time.now
      # )
      @boardcast_thread = Thread.new do
        loop do
          receiver_message = @message_queue.pop
          @delivery_queues.each do |q|
            q.push receiver_message
          end
        end
      end
    end

    def register_user(register_user_request, _unused_call)
      user_name = register_user_request.user_name
      if @user_names.include?(user_name)
        RegisterUserResponse.new(status: :REJECT)
      else
        @user_names.add user_name
        session_id  = SecureRandom.uuid
        @session_ids[session_id] = user_name
        RegisterUserResponse.new(status: :OK, session_id: session_id)
      end
    end

    def list_users(list_request, _unused_call)
      query = list_request.query.strip
      if query.empty? || query == '.'
        ListUsersResponse.new size: @user_names.size, user_names: @user_names.to_a
      else
        pattern = Regexp.new(query)
        user_names = @user_names.grep(pattern)
        ListUsersResponse.new size: user_names.size, user_names: user_names
      end
    rescue Exception => e
      ListUsersResponse.new size: @user_names.size, user_names: @user_names.to_a
    end

    def listen(listen_quest, _unused_call)
      q = EnumeratorQueue.new self
      @delivery_queues << q
      now = Time.now
      welcome = ReceiverMessage.new(
        uuid: "0",
        user_name: "system",
        text: "Welcome, there are currently #{@user_names.size} agents in the room.",
        timestamp: Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)
      )
      q.push welcome
      q.each
    end
  end

  class EnumeratorQueue
    extend Forwardable
    def_delegators :@q, :push

    def initialize(sentinel)
      @q = Queue.new
      @sentinel = sentinel
    end

    def each
      return enum_for(:each) unless block_given?
      loop do
        r = @q.pop
        break if r.equal?(@sentinel)
        raise r if r.is_a? Exception
        yield r
      end
    end
  end
end
