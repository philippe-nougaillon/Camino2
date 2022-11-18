class AddSlugToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :slug, :string
    add_index :projects, :slug, unique: true

    Project.find_each(&:save)
  end
end
