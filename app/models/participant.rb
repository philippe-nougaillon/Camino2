class Participant < ApplicationRecord
  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :project
  belongs_to :user

  validates :user_id, uniqueness: { scope: :project_id }

  scope :notification_subcribers, -> {where(want_notification:true)} 

  private

  def slug_candidates
    [SecureRandom.uuid]
  end

end
