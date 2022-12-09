class ParticipantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def edit?
    record.user == user
  end

  def update?
    edit?
  end
end
