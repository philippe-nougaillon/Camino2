class TablePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user.admin?
  end

  def show?
    index? && record.account.users.include?(user)
  end

  def new?
    index?
  end

  def create?
    new?
  end

  def edit?
    show?
  end

  def update?
    edit?
  end

  def destroy?
    show?
  end

  def fill?
    true
  end

  def fill_do?
    fill?
  end

  def show_attrs?
    show?
  end

  def link?
    show?
  end

  def link_do?
    link?
  end

  def delete_record?
    show?
  end

end
