class ProjectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    true
  end

  def show?
    record.users.include?(user)
  end

  def new?
    user.admin?
  end

  def create?
    new?
  end

  def edit?
    show? && user.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def invite?
    user.admin? && record.users.include?(user)
  end

  def invite_do?
    invite?
  end

  def save_as_template?
    user.admin?
  end

  def save_as_template_post?
    save_as_template?
  end

  def accepter
    true
  end
end
