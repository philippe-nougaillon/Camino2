class AddSlugToTodolists < ActiveRecord::Migration[7.0]
  def change
    add_column :todolists, :slug, :string
    add_index :todolists, :slug, unique: true

    Todolist.find_each(&:save)
  end
end
