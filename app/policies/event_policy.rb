class EventPolicy < ApplicationPolicy
  def show?
    true
  end

  def my_events?
    true
  end

  def new?
    true
  end

  def edit?
    record.host_id == user.id
  end

  # Only the host can open the "invite your partners" list for their event.
  def invite_partners_list?
    record.host_id == user.id
  end

  def update?
    record.host_id == user.id
  end

  def create?
    true
  end

  def destroy?
    record.host_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
