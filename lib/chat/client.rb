require 'grpc'
require 'protos/chat_services_pb'
require 'chat/enumerator'
require 'securerandom'

module Chat
  class Client
    def self.sender_message(session_id, text)
      SenderMessage.new(
        uuid: SecureRandom.uuid,
        session_id: session_id,
        text: text
      )
    end

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

    def send(session_id, messages, return_op=false)
      @stub.send(messages.each, return_op: return_op)
    end
  end
end
