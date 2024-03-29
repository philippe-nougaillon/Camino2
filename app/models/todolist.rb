class Todolist < ApplicationRecord
  include LogConcern

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  belongs_to :project

  has_many :todos, dependent: :destroy
  has_many :logs, dependent: :destroy

  validates :name, presence: true

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

  private

  def slug_candidates
    [SecureRandom.uuid]
  end

end
