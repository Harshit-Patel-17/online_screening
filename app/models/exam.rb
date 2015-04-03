class Exam < ActiveRecord::Base
	serialize :question_count_per_weightage, JSON

	def set_test test
		qpw = Question.questions_per_weightage
		test.each do |key, value|
			key = key.to_i
			return false unless qpw.has_key? key
			return false if qpw[key] < value
		end
		formatted_test = []
		test.each do |key, value|
			temp = Hash.new
			temp[:weightage] = key.to_i
			temp[:count] = value
			formatted_test.push temp
		end
		puts formatted_test.class
		self.question_count_per_weightage = formatted_test
		self.save
		return true
	end

	def set_questions question_ids
		questions = Question.where('id IN (?)', question_ids)
		qpw = questions.group(:weightage).count
		self.question_count_per_weightage.each do |qcpw|
			weightage = qcpw['weightage']
			count = qcpw['count']
			return false unless qpw.has_key? weightage
			return false if qpw[weightage] < count
		end
		question_ids.each do |qid|
			eq = ExamQuestion.new
			eq[:exam_id] = self.id
			eq[:question_id] = qid
			eq.save
		end
		return true
	end
end
