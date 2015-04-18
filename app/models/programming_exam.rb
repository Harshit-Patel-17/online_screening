class ProgrammingExam < ActiveRecord::Base
	has_many :programming_exam_tasks, :dependent => :delete_all
	has_many :programming_tasks, through: :programming_exam_tasks
	has_many :programming_exam_colleges, :dependent => :delete_all
	has_many :colleges, :through => :programming_exam_colleges
	has_many :programming_answer_sheets, :dependent => :delete_all

	def get_programming_task_ids
		retValue = []
		programming_exam = self
		programming_exam_tasks = programming_exam.programming_exam_tasks
		programming_exam_tasks.each do |exam_task|
			retValue.push(exam_task.programming_task_id)
		end
		return retValue
	end

	def set_programming_tasks programming_task_ids
		old_programming_exam_tasks = self.programming_exam_tasks
		old_programming_exam_tasks.delete_all
		if programming_task_ids != nil
			programming_task_ids.each do |id|
				programming_exam_task = ProgrammingExamTask.new
				programming_exam_task.programming_exam_id = self.id
				programming_exam_task.programming_task_id = id
				programming_exam_task.save
			end
		end
		return true
	end

	def set_colleges college_ids
		old_exam_colleges = self.programming_exam_colleges
		old_exam_colleges.delete_all
		if college_ids != nil
			college_ids.each do |cid|
				pec = ProgrammingExamCollege.new
				pec[:programming_exam_id] = self.id
				pec[:college_id] = cid
				pec.save
			end
		end
		return true
	end

	def self.get_for_user user_id
		user = User.find user_id
		programming_exams = user.college.programming_exams
		return programming_exams
	end

	def is_window_open?
		programming_exam = self
		swt = programming_exam.start_window_time
		ewt = programming_exam.end_window_time
		now = DateTime.now.utc
		window_open = swt <= now and ewt >= now
	end
end
