class ExamQuestion < ActiveRecord::Base
	belongs_to :exam
  belongs_to :question

  def self.get_for_exam exam_id
  	retVal = []
  	questions = ExamQuestion.where('exam_id = ?', exam_id)
  	questions.each do |q|
  		retVal.push(q.question_id)
  	end
  	return retVal
  end
end
