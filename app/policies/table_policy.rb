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
    index?
  end

  def new?
    index?
  end

  def create?
    new?
  end

  def edit?
    index?
  end

  def update?
    edit?
  end

  def destroy?
    index?
  end

  def fill?
    index?
  end

  def fill_do?
    fill?
  end

  def show_attrs?
    index?
  end
end
