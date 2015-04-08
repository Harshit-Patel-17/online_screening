class ExamQuestion < ActiveRecord::Base
	belongs_to :exam
  belongs_to :question

  def self.get_for_exam exam_id, question_category_id
  	retVal = []
    exam = Exam.find(exam_id)
  	questions = exam.questions.where('question_category_id = ?', question_category_id).select(:id)
    questions.each do |q|
  		retVal.push(q.id)
  	end
  	return retVal
  end
end
