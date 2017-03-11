require 'grpc'
require 'protos/chat_services_pb'


module Chat
  class Client
    def initialize(uri, auth=:this_channel_is_insecure)
      @stub = Room::Stub.new(uri, auth)
    end

    def register_user(user_name)
      @stub.register_user RegisterUserRequest.new(user_name: user_name)
    end

    def list_users(query)
      @stub.list_users ListUsersRequest.new(query: query)
    end

    def listen
      @stub.listen ListenRequest.new
    end
  end
end
