class AddAccountReferenceToMailLog < ActiveRecord::Migration[7.0]
  def change
    add_reference :mail_logs, :account, null: false, foreign_key: true
  end
end
