class AnswerSheet < ActiveRecord::Base
	belongs_to :user
	belongs_to :exam
	serialize :answer, JSON
	serialize :result, JSON 
  
	def self.set answer_sheet
		as = AnswerSheet.new(answer_sheet)
		as.start_time = Time.now

		exam_id = as.exam_id
		exam = Exam.find(exam_id)
		question_ids = exam.exam_questions.select(:question_id)

		qcpw = exam.question_count_per_weightage
		questions = []
		answers = []
		qcpw.each do |i|
			weightage = i['weightage']
			count = i['count']
			temp_questions_ids = Question.where('id in (?) and weightage = ?', question_ids, weightage).select(:id)
			temp_question_ids = temp_questions_ids.shuffle
			puts temp_question_ids
			temp_questions_ids[0..count-1].each {|q| questions.push(q.id)}
		end
		as.questions = questions
		as.answers = answers
		as.save
		return as
	end
end
