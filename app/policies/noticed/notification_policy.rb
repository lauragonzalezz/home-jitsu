module Noticed
  class NotificationPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      # A user only ever sees their own notifications.
      def resolve
        scope.where(recipient: user)
      end
    end
  end
end
