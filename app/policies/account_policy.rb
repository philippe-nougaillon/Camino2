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

  def suppression_compte?
    user.admin? && user.account = record
  end

  def suppression_compte_do?
    suppression_compte?
  end

end
