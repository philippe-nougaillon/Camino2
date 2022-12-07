class AddSlugToTables < ActiveRecord::Migration[7.0]
  def change
    add_column :tables, :slug, :string
    add_index :tables, :slug, unique: true

    Table.find_each(&:save)
  end
end
