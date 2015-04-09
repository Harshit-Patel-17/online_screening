class Question < ActiveRecord::Base
	has_many  :exam_questions
	has_many :exams, :through => :exam_questions

	serialize :options, Array
	serialize :answers, Array
	
	def self.set question, image
		question = question.symbolize_keys
		question[:options] = [] if question[:qtype] == 'numerical'
		question[:options] = question[:options] || [] unless question[:qtype] == 'numerical'
		q = Question.new(question)
		if image
			q.upload_image! image
			return q
		else
			q.save
			return q
		end
		return false
	end

	def edit! question, image
		question = question.symbolize_keys
		question[:options] = [] if question[:qtype] == 'numerical'
		question[:options] = question[:options] || [] unless question[:qtype] == 'numerical'
		q = self
		if q.image and image
			q.delete_image!
		end
		q.update(question)
		if image
			q.upload_image! image
			return q
		else
			return q
		end
		return false
	end

	def remove
		if self.image
			self.delete_image!
		end
		self.delete
	end

	def upload_image! image
		name = Time.now.to_s + image.original_filename
		directory = "public/images"
		path = File.join(directory, name)
		File.open(path, "wb"){|f| f.write(image.read)}
		self.image = name
		self.save
	end

	def delete_image!
		name = self.image
		directory = "public/images"
		path = File.join(directory, name)
		if File.exist? path
			File.delete(path)
		end
		self.image = nil
		self.save
	end

	def self.questions_per_weightage
		retVal = Hash.new
		question_categories = Question.group(:question_category_id).select(:question_category_id)
		question_categories.each do |qc|
			retVal[qc.question_category_id] = Question.where('question_category_id = ?', qc.question_category_id).group(:weightage).count
		end
		return retVal
	end

	def self.get_for_exam exam_id, question_category_id
		question_category_name = QuestionCategory.find(question_category_id).category_name
		qcpw = Exam.find(exam_id).question_count_per_weightage[question_category_name]
		weightages = []
		if qcpw
			qcpw.each do |i|
				weightages.push i['weightage']
			end
		end
		questions = Question.where('question_category_id = ?', question_category_id)
		questions = questions.where('weightage IN (?)', weightages)
	end
end
