class ProgrammingExamCollege < ActiveRecord::Base
	belongs_to :programming_exam
  belongs_to :college

  def self.get_for_programming_exam programming_exam_id
  	retVal = []
  	colleges = ProgrammingExamCollege.where('programming_exam_id = ?', programming_exam_id)
  	colleges.each do |c|
  		retVal.push(c.college_id)
  	end
  	return retVal
  end
end
