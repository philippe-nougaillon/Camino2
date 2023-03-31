class UpdateProjectsColor < ActiveRecord::Migration[7.0]
  def change
    Project.where(color: nil).update_all(
      color: "#38cdbe"
    )
  end
end
