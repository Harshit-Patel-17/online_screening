class AnswerSheet < ActiveRecord::Base
	belongs_to :user
	belongs_to :exam
	serialize :questions, Array
	serialize :answers, Array
  
	def self.set answer_sheet
		answer_sheet = answer_sheet.symbolize_keys
		as = AnswerSheet.where('exam_id = ? and user_id = ?', answer_sheet[:exam_id], answer_sheet[:user_id])
		
		return as[0] unless as.length == 0
		
		as = AnswerSheet.new(answer_sheet)

		exam_id = as.exam_id
		exam = Exam.find(exam_id)
		swt = exam.start_window_time
		ewt = exam.end_window_time
		now = DateTime.now.change(:offset => "+0000")
		window_active = swt <= now and ewt >= now
		unless window_active
			return false
		end
		as.start_time = DateTime.now
		as.end_time = as.start_time + exam.duration_mins.minutes
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
			temp_questions_ids[0..count-1].each do |q|
				questions.push(q.id)
				answers.push([])
			end
		end
		as.questions = questions
		as.answers = answers
		as.save
		return as
	end

	def self.calculate_result exam_id, cut_off
		retValue = []
		answer_sheets = AnswerSheet.where('exam_id = ?', exam_id)
		answer_sheets.each do |as|
			if as.score != nil
				next
			end
			score = 0
			question_ids = as.questions
			question_ids.each_with_index do |qid, index|
				question = Question.find(qid)
				actual_answers = question.answers.sort
				given_answers = as.answers[index].sort
				if actual_answers == given_answers
					score = score + question.weightage
				end
			end
			as.score = score
			as.save
		end

		if cut_off
			answer_sheets = answer_sheets.where('score >= ?', cut_off)
		end

		answer_sheets.each do |as|
			user = User.find as.user_id
			answer_sheet_json = as.as_json
			user_name = user.first_name + ' '
			user_name = user_name + user.last_name if user.last_name
			answer_sheet_json[:user_name] = user_name
			retValue.push(answer_sheet_json)
		end
		retValue
	end
end
