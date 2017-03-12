# A Ruby gRPC Chatroom Demo

This is a toy chatroom demo using Ruby & gRPC.  

## Running the Demo

`bundle install`

`bin/server` will start the chat server at default port 50051.

`bin/register_user user_name` will register a user_name with the server.  Upon success, user will be given a `session_id` to be used for sending messages to the server.  Think of this as an access token.  All user_names must be *unique* on the server and each `user_name` only has one `session_id`.  There is no way to unregister.

`bin/randoms session_id` will create a random chat bot using the given `session_id` that generates 0-5 messages every 0-5 seconds.

`bin/randoms` will create 10 random chat bots & register them with the server.

`bin/listen` will stream & print out all messages going through the chatroom service.  You don't need a `session_id`.

`bin/list_users Regpex` will list all user_names currently registered on the server matching the regular expression pattern that is given. You don't need a `session_id` to `list_users`.

See [protos/chat.proto](protos/chat.proto) for the service's API spec.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
