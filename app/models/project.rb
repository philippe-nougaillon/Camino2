class Project < ApplicationRecord
  include LogConcern
  extend SimpleCalendar

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  acts_as_taggable
    
    #has_calendar :attribute => :created_at  

  belongs_to :account

  has_many :todolists, dependent: :destroy
  has_many :todos, through: :todolists
  has_many :comments, through: :todos
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :logs, dependent: :destroy

  validates :name, presence: true
  validates :workflow, presence: true

  default_scope {order('projects.name')}

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
    lists = self.todolists.reorder(:row).select{|l| !l.done? }
    return lists.first
  end

  def daily_logs
    self.logs.where(created_at: 1.days.ago.to_date..Date.today).reorder(:created_at)
  end

  def weekly_logs
    self.logs.where(created_at: 7.days.ago.to_date..Date.today).reorder(:created_at)
  end

  private

  def slug_candidates
    [SecureRandom.uuid]
  end
end
