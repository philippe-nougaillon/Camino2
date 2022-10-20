class Todolist < ApplicationRecord
  include LogModule

  	belongs_to :project
  	has_many :todos, dependent: :destroy
	has_many :logs

  	validates :name, presence:true

	def pct_avancee 
		((self.todos.done.count * 100)  / self.todos.count)
	end

	def done?
		((self.todos.any?) and (self.todos.done.count == self.todos.count))
	end

	def name_with_indice
		"#{self.row} - #{self.name}"
	end

	def next_todo
		todos = self.todos.select{|t| !t.done}
		todos.first
	end	

	def bar_avancee
		"<span id='progress'>#{'.' * (self.pct_avancee / 10)}</span><span id='progress_done'>#{'.' * (10 - (self.pct_avancee / 10))}</span>"
    end  

end
