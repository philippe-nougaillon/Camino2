class AdminPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def stats?
    user && ['pierreemmanuel.dacquet@gmail.com', 'philippe.nougaillon@gmail.com'].include?(user.email)
  end

  def suppression_compte?
    stats?
  end
end
