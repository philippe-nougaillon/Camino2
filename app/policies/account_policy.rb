class AccountPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def edit?
    user.admin? && record.users.include?(user)
  end

  def update?
    edit?
  end

end
