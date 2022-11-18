class PagesPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def about?
    true
  end

  def dashboard?
    user.admin?
  end
end
