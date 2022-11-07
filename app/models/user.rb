class User < ApplicationRecord
  audited

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
        # :registerable,
        # :recoverable,
        :rememberable, :validatable

  has_one_attached :avatar

  belongs_to :account

  has_many :participants
  has_many :projects, through: :participants
  has_many :logs, through: :projects
  has_many :comments, through: :projects
  has_many :todos 

  validates :password, length: { minimum: 5 }
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true
end
