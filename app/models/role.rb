class Role < ActiveRecord::Base
	has_many :privileges
	has_many :users, through: :privileges
end
