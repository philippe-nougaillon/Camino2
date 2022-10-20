class Table < ApplicationRecord

	belongs_to :account

	has_many :fields, dependent: :destroy
	has_many :values, dependent: :destroy
	has_many :projects

	validates_presence_of :name

	def size
		self.values.group(:record_index).count.size
	end
end
