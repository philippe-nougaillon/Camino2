class Account < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  has_many :projects, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :tables, dependent: :destroy
  has_many :mail_logs, dependent: :destroy

  has_many :values, through: :tables
  has_many :participants, through: :projects
  has_many :todolists, through: :projects
  has_many :todos, through: :todolists
  has_many :comments, through: :users

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
