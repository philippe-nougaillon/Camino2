class Project < ApplicationRecord
  include LogConcern
  extend SimpleCalendar

  audited

  acts_as_taggable
    
    #has_calendar :attribute => :created_at  

  belongs_to :account

  has_many :todolists, dependent: :destroy
  has_many :todos, through: :todolists, dependent: :destroy
  has_many :comments, through: :todos
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :logs

  validates :name, presence: true
  validates :workflow, presence: true

  def pct_avancee 
    unless self.todos.count.zero?
      ((self.todos.done.count * 100)  / self.todos.count)
    else
      0
    end
  end

  def bar_avancee
    "<span id='progress'>#{'.' * (self.pct_avancee / 10)}</span><span id='progress_done'>#{'.' * (10 - (self.pct_avancee / 10))}</span>"
    end        

  def last_update
    if self.logs.any?
      self.logs.maximum(:created_at)
    else
      Date.today
    end
  end

  def workflow?
    self.workflow == 1
  end

  def current_todolist
    lists = self.todolists.order(:row).select{|l| !l.done? }
    return lists.first
  end
    
end
