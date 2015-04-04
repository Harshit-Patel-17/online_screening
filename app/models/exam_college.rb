class ExamCollege < ActiveRecord::Base
	belongs_to :exam
  belongs_to :college
end
