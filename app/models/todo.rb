class Todo < ApplicationRecord
  include LogConcern

  audited

  acts_as_taggable

  belongs_to :todolist
  belongs_to :user

  has_one :project, through: :todolist

  has_one_attached :document

  has_many :comments
  has_many :values

  validates :name, presence: true

  scope :done, -> {where(done:true)} 
  scope :undone, -> {where(done:false)} 

  def preview_name
    if File.extname(self.docname) == ".pdf"
      "/documents/#{self.docfilename}.png"
    else
      "/documents/#{self.docfilename}"
    end
  end

  def fullname
    "#{self.project.name}:#{self.todolist.name}:#{self.name}"
  end  

end
