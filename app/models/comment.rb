class Comment < ApplicationRecord
  include LogConcern

  # Crash à cause de l'appel du current_user dans le partial comments/comment
  # after_create_commit { broadcast_prepend_to :comments }

  audited

  belongs_to :todo
  belongs_to :user

  has_one :todolist, through: :todo
  has_one :project, through: :todolist

  default_scope {order('comments.created_at DESC')} 

end
