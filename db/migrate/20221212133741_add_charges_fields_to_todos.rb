class AddChargesFieldsToTodos < ActiveRecord::Migration[7.0]
  def change
    add_column :todos, :charge_est, :decimal, precision: 7, scale: 2, default: '0.0'
    add_column :todos, :charge_reelle, :decimal, precision: 7, scale: 2, default: '0.0'
  end
end
