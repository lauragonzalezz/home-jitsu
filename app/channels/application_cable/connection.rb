module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    # Devise signs the user in through Warden, which is available on the Rack
    # env during the WebSocket handshake. No signed-in user => no connection.
    def find_verified_user
      env["warden"]&.user || reject_unauthorized_connection
    end
  end
end
