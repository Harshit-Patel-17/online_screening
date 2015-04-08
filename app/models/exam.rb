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
		e.question_count_per_weightage = {}
		e.save
		e
	end

	def set_scheme! test, question_category_id
		qpw = Question.questions_per_weightage question_category_id
		test.each do |key, value|
			key = key.to_i
			value = (value || "").to_i
			return false unless qpw.has_key? key
			return false if qpw[key] < value
		end
		old_questions = self.questions.where('question_category_id = ?', question_category_id).select(:id)
		old_question_ids = []
		old_questions.each do |q|
			old_question_ids.push(q.id)
		end
		old_exam_questions = ExamQuestion.where('question_id in (?)', old_question_ids)
		old_exam_questions.delete_all
		question_category_name = QuestionCategory.find(question_category_id).category_name
		formatted_test = self.question_count_per_weightage || {}
		formatted_test[question_category_name] = []
		test.each do |key, value|
			temp = Hash.new
			temp[:weightage] = key.to_i
			temp[:count] = value.to_i
			formatted_test[question_category_name].push(temp) if temp[:count] > 0
		end
		self.question_count_per_weightage = formatted_test
		self.save
		return true
	end

	def set_questions question_ids, question_category_id
		questions = Question.where('id IN (?)', question_ids)
		qpw = questions.group(:weightage).count
		question_category_name = QuestionCategory.find(question_category_id).category_name
		return false unless self.question_count_per_weightage.has_key? question_category_name
		self.question_count_per_weightage[question_category_name].each do |qcpw|
			weightage = qcpw['weightage']
			count = qcpw['count']
			return false unless qpw.has_key? weightage
			return false if qpw[weightage] < count
		end
		old_questions = self.questions.where('question_category_id = ?', question_category_id).select(:id)
		old_question_ids = []
		old_questions.each do |q|
			old_question_ids.push(q.id)
		end
		old_exam_questions = ExamQuestion.where('question_id in (?)', old_question_ids)
		old_exam_questions.delete_all
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

	def get_question_count_per_weightage question_category_id
		retVal = Hash.new
		question_category_name = QuestionCategory.find(question_category_id).category_name
		if self.question_count_per_weightage.has_key? question_category_name
			self.question_count_per_weightage[question_category_name].each do |qcpw|
				retVal[qcpw['weightage']] = qcpw['count']
			end
		end
		return retVal
	end

	def self.get_for_user user_id
		user = User.find user_id
		exams = user.college.exams
		return exams
	end

	def get_question_categories
		retVal = Array.new
		self.question_count_per_weightage.each do |key, value|
			temp = Hash.new
			key = key.to_s
			temp[:category_name] = key
			temp[:id] = QuestionCategory.find_by_category_name(key).id
			retVal.push(temp)
		end
		return retVal
	end
end
