class CreateMailLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :mail_logs do |t|
      t.string :to
      t.string :subject
      t.string :message_id

      t.timestamps
    end
  end
end
