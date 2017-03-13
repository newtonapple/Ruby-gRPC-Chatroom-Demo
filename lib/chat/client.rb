require 'grpc'
require 'protos/chat_services_pb'
require 'chat/enumerator'
require 'securerandom'

module Chat
  class Client
    def initialize(uri, auth: :this_channel_is_insecure)
      @stub = Room::Stub.new(uri, auth)
    end

    def register_user(user_name)
      @stub.register_user RegisterUserRequest.new(user_name: user_name)
    end

    def list_users(query)
      @stub.list_users ListUsersRequest.new(query: query)
    end

    def listen(return_op=false)
      @stub.listen(ListenRequest.new, return_op: return_op)
    end
  end

  class RegisteredClient < Client
    attr_accessor :session_id
    attr_reader :message_responses

    def initialize(uri, session_id, auth: :this_channel_is_insecure)
      @stub = Room::Stub.new(uri, auth)
      @session_id = session_id
      @messages = EnumeratorQueue.new self
      @message_responses = @stub.send(@messages.each)
    end

    def send(text)
      @messages.push SenderMessage.new(
        uuid: SecureRandom.uuid,
        session_id: @session_id,
        text: text
      )
    end
  end
end
