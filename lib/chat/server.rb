require 'grpc'
require 'protos/chat_services_pb'
require 'set'
require 'securerandom'

module Chat
  class Server < Room::Service
    def initialize
      @session_ids = {}  # user_name to session_id mapping
      @user_names  = Set.new
    end

    def join(join_request, _unused_call)
      user_name = join_request.user_name
      if @user_names.include?(user_name)
        JoinResponse.new(status: :REJECT)
      else
        @user_names.add user_name
        session_id  = SecureRandom.uuid
        @session_ids[user_name] = session_id
        JoinResponse.new(status: :OK, session_id: session_id)
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
  end
end
