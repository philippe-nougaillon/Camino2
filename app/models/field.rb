class Field < ActiveRecord::Base
	belongs_to :table
	has_many :values

	validates_presence_of :name
	validates_presence_of :datatype

	enum datatype: [:texte, :nombre, :euros, :date, :oui_non?, :liste]

end
