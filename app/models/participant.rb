class Participant < ApplicationRecord

  	belongs_to :project
  	belongs_to :user	

	scope :notification_subcribers, -> {where(want_notification:true)} 

end
