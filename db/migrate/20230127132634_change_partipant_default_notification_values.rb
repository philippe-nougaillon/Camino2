class ChangePartipantDefaultNotificationValues < ActiveRecord::Migration[7.0]
  def change
    change_column :participants, :want_notification, :boolean, default: false
    change_column :participants, :want_dailynewsletter, :boolean, default: true
    change_column :participants, :want_weeklynewsletter, :boolean, default: true

    Participant.update_all(
      want_notification: false,
      want_dailynewsletter: true,
      want_weeklynewsletter: true
    )
  end
end
