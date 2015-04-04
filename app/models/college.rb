class College < ActiveRecord::Base
	has_many :exam_colleges
	has_many :exams, :through => :exam_colleges
	has_many :users
end
