class Account < ApplicationRecord
  audited

  has_many :projects
  has_many :templates
  has_many :users
  has_many :tables
  has_many :values, through: :tables
  
  has_many :participants, through: :projects
  has_many :todolists, through: :projects
  has_many :todos, through: :todolists

  accepts_nested_attributes_for :users	

  validates :name, presence: true, uniqueness: true

  # has_attached_file :logo, :styles => { :thumb => "60x60>" }, :default_url => "new_logo.png"
  # validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/
  
end
