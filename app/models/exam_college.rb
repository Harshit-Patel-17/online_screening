class ExamCollege < ActiveRecord::Base
	belongs_to :exam
  belongs_to :college

  def self.get_for_exam exam_id
  	retVal = []
  	colleges = ExamCollege.where('exam_id = ?', exam_id)
  	colleges.each do |c|
  		retVal.push(c.college_id)
  	end
  	return retVal
  end
end
