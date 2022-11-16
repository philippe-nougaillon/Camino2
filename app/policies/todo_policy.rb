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
    (show? && user.admin?) || record.audits.first.user == user
  end

  def update?
    true
  end

  def destroy?
    edit?
  end
end
