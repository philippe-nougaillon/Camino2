class AddSlugToTodos < ActiveRecord::Migration[7.0]
  def change
    add_column :todos, :slug, :string
    add_index :todos, :slug, unique: true

    Todo.find_each(&:save)
  end
end
