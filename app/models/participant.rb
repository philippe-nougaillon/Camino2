class Participant < ApplicationRecord
  audited

  belongs_to :project
  belongs_to :user

  validates :user_id, uniqueness: { scope: :project_id }

  scope :notification_subcribers, -> {where(want_notification:true)} 

end
