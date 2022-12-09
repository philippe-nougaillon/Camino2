class TodoPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    true
  end

  def show?
    record.todolist.project.users.include?(user)
  end

  def new?
    user.admin?
  end

  def create?
    new?
  end

  def edit?
    show?
  end

  def update?
    (show? && user.admin?) || record.user == user
  end

  def destroy?
    update?
  end

  # /documents/purge
  def purge?
    (user.admin? && user.same_account(record.user)) || record.user == user
  end
end
