class Comment < ApplicationRecord
  include LogConcern

  audited

  belongs_to :todo
  belongs_to :user

  has_one :todolist, through: :todo
  has_one :project, through: :todolist

  default_scope {order('comments.created_at DESC')} 

end
