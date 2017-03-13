require 'grpc'
require 'protos/chat_services_pb'
require 'set'
require 'securerandom'
require 'thread'
require 'chat/enumerator'

module Chat
  class Server < Room::Service
    def initialize
      @session_ids = {}  # session_id to user_name mapping
      @user_names  = Set.new
      @message_queue  = Queue.new
      @broadcast_queues = {}
      @broadcast_thread = Thread.new do
        loop do
          receiver_message = @message_queue.pop
          dead = []
          puts @broadcast_queues.size
          @broadcast_queues.each do |listen_call, q|
            if listen_call.cancelled?
              dead << listen_call
            else
              q.push receiver_message
            end
          end
          dead.each{ |dead_listen_call| @broadcast_queues.delete(dead_listen_call) }
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

    def listen(listen_request, listen_call)
      q = EnumeratorQueue.new self
      @broadcast_queues[listen_call] = q
      now = Time.now
      welcome = ReceiverMessage.new(
        uuid: SecureRandom.uuid,
        user_name: "SYSTEM",
        text: "Welcome, there are currently #{@user_names.size} agents in the room.",
        timestamp: Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)
      )
      q.push welcome
      q.each
    end

    def send(messages, _unused_call)
      EnumeratorFiber.new(self) do
        messages.each do |sender_message|
          user_name = @session_ids[sender_message.session_id]
          text      = sender_message.text
          uuid      = sender_message.uuid
          now       = Time.now
          ts        = Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)
          response  = SenderMessageResponse.new(uuid: uuid, timestamp: ts)
          if user_name.nil?
            response.status = :REJECT
          elsif text.empty? || uuid.empty?
            response.status = :ERROR
          else
            @message_queue.push ReceiverMessage.new(
              uuid: uuid,
              user_name: user_name,
              text: text,
              timestamp: ts
            )
          end
          Fiber.yield response
        end
        Fiber.yield self
      end.each
    end
  end
end
