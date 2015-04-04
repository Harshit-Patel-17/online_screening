class Exam < ActiveRecord::Base
	has_many :exam_questions, :dependent => :delete_all
	has_many :questions, :through => :exam_questions
	has_many :exam_colleges, :dependent => :delete_all
	has_many :colleges, :through => :exam_colleges
	has_many :answer_sheets, :dependent => :delete_all

	serialize :question_count_per_weightage, JSON

	def self.set exam
		e = Exam.new exam.symbolize_keys
		e.status = 'inactive'
		e.question_count_per_weightage = []
		e.save
		e
	end

	def set_scheme! test
		old_exam_questions = self.exam_questions
		old_exam_questions.delete_all
		qpw = Question.questions_per_weightage
		test.each do |key, value|
			key = key.to_i
			value = (value || "").to_i
			return false unless qpw.has_key? key
			return false if qpw[key] < value
		end
		formatted_test = []
		test.each do |key, value|
			temp = Hash.new
			temp[:weightage] = key.to_i
			temp[:count] = value.to_i
			formatted_test.push(temp) if temp[:count] > 0
		end
		puts formatted_test.class
		self.question_count_per_weightage = formatted_test
		self.save
		return true
	end

	def set_questions question_ids
		old_exam_questions = self.exam_questions
		old_exam_questions.delete_all
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

	def set_colleges college_ids
		old_exam_colleges = self.exam_colleges
		old_exam_colleges.delete_all
		college_ids.each do |cid|
			ec = ExamCollege.new
			ec[:exam_id] = self.id
			ec[:college_id] = cid
			ec.save
		end
		return true
	end

	def get_question_count_per_weightage
		retVal = Hash.new
		self.question_count_per_weightage.each do |qcpw|
			retVal[qcpw['weightage']] = qcpw['count']
		end
		return retVal
	end

	def self.get_for_user user_id
		user = User.find user_id
		exams = user.college.exams
		return exams
	end
end
