class AnswerSheet < ActiveRecord::Base
	belongs_to :user
	belongs_to :exam
	serialize :questions, JSON
	serialize :answers, JSON
  
	def self.set answer_sheet
		answer_sheet = answer_sheet.symbolize_keys

		exam_id = answer_sheet[:exam_id]
		exam = Exam.find(exam_id)
		
		as = AnswerSheet.new(answer_sheet)
		as.start_time = DateTime.now
		as.end_time = as.start_time + exam.duration_mins.minutes
		question_ids = exam.exam_questions.select(:question_id)

		qcpw = exam.question_count_per_weightage
		questions = {}
		answers = {}
		qcpw.each do |category, scheme|
			question_category_id = QuestionCategory.find_by_category_name(category)
			questions[category] = []
			answers[category] = []
			scheme.each do |i|
				weightage = i['weightage']
				count = i['count']
				temp_questions_ids = Question.where('id in (?) and weightage = ? and question_category_id = ?', question_ids, weightage, question_category_id).select(:id)
				temp_question_ids = temp_questions_ids.shuffle
				puts temp_question_ids
				temp_questions_ids[0..count-1].each do |q|
					questions[category].push(q.id)
					answers[category].push([])
				end
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
			score = 0
			scheme = as.questions
			scheme.each do |category, question_ids|
				question_ids.each_with_index do |qid, index|
					question = Question.find(qid)
					actual_answers = question.answers.sort
					given_answers = as.answers[category][index].sort
					if actual_answers == given_answers
						score = score + question.weightage
					end
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

	def self.get_for_users params
		users = User.all
		users = users.where('first_name like ?', params[:first_name] + "%") if params[:first_name] and params[:first_name] != ""
	    users = users.where('email like ?', params[:email] + "%") if params[:email] and params[:email] != ""
	    users = users.where('college_id = ?', params[:college_id] + "%") if params[:college_id] and params[:college_id] != ""
	    user_ids = users.select(:id)

	    answer_sheets = AnswerSheet.where("exam_id = ? and user_id in (?)", params[:exam_id], user_ids)
	end
end
