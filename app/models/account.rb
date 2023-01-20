class Account < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  has_many :projects
  has_many :templates
  has_many :users
  has_many :tables
  has_many :values, through: :tables
  
  has_many :participants, through: :projects
  has_many :todolists, through: :projects
  has_many :todos, through: :todolists
  has_many :mail_logs

  accepts_nested_attributes_for :users

  validates :name, presence: true, uniqueness: true

  after_create :account_notification

  # has_attached_file :logo, :styles => { :thumb => "60x60>" }, :default_url => "new_logo.png"
  # validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/
  
  private

  def slug_candidates
    [SecureRandom.uuid]
  end

  def account_notification
    Notifier.with(account: self).new_account_notification.deliver_now
  end
end
