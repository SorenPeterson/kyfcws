require 'em-websocket'
require 'json'
require 'debugger'

groups = {}

class Group
  attr_accessor :users, :log

  def initialize()
    @users = []
    @log = []
  end
end

EM.run {
  EM::WebSocket.run(host: "0.0.0.0", port: 8080) do |connection|
    connection.onopen { |handshake|

    }

    connection.onclose {
      p 'deleting connection'
      p @group.users.count
      @group.users.delete(connection)
      p @group.users.count
    }

    connection.onmessage { |msg|
      # if the message contains group information, switch the group.
      data = JSON.parse(msg)
      p data

      if(data["type"] == "connect")
        @group = (groups[data["group_id"]] ||= Group.new)
        @group.users << connection

        @group.log.each do |logged_msg|
          connection.send(logged_msg)
        end

      elsif(data["type"] == "message")

        @group.users.each do |user|
          user.send(data["message"])
        end

        @group.log << data["message"]

      end
    }
  end
}