class Table < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  belongs_to :account

  has_many :fields, dependent: :destroy
  has_many :values, dependent: :destroy
  has_many :projects

  validates_presence_of :name

  def size
    self.values.group(:record_index).count.size
  end

  private

  def slug_candidates
    [SecureRandom.uuid]
  end
end
