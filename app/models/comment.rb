require 'concerns/logmodule.rb'

class Comment < ActiveRecord::Base
	include LogModule

	belongs_to :todo
	belongs_to :user

	has_one :todolist, through: :todo
	has_one :project, through: :todolist

	default_scope {order('created_at DESC')} 

end