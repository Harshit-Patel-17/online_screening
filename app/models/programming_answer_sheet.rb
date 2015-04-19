class ProgrammingAnswerSheet < ActiveRecord::Base
	belongs_to :user
	belongs_to :programming_exam
	serialize :programming_tasks, JSON
	serialize :marks, JSON

	@@sandbox_path = "online_judge/sandbox_C"
	@@programs_path = @@sandbox_path + "/programs"
	@@admin_programs_path = @@sandbox_path + "/admin_programs"
	@@test_output_directory = @@sandbox_path + "/test/output"
	@@password = "infibeam"

	def self.set programming_answer_sheet
		programming_answer_sheet = programming_answer_sheet.symbolize_keys
		programming_exam_id = programming_answer_sheet[:programming_exam_id]
		programming_exam = ProgrammingExam.find(programming_exam_id)

		pas = ProgrammingAnswerSheet.new(programming_answer_sheet)
		pas.start_time = DateTime.now
		pas.end_time = pas.start_time + programming_exam.duration_mins.minutes

		programming_task_ids = programming_exam.programming_exam_tasks.select(:programming_task_id)
		programming_tasks = []
		marks = []

		programming_task_ids.each do |pt|
			programming_tasks.push(pt.programming_task_id)
			marks.push(0)
		end

		pas.programming_tasks = programming_tasks
		pas.marks = marks
		pas.save

		system("echo '#{@@password}' | sudo -S mkdir #{@@programs_path}/#{pas.id}")
		system("echo '#{@@password}' | sudo -S touch #{@@programs_path}/#{pas.id}/stdout")
		system("echo '#{@@password}' | sudo -S touch #{@@programs_path}/#{pas.id}/stdin")

		return pas
	end

	def get_task_names
		retVal = []
		self.programming_tasks.each do |programming_task_id|
			retVal.push(ProgrammingTask.find(programming_task_id).task_name)
		end
		return retVal
	end

	def save_program programming_task_id, program_text
		program_text = program_text.strip.gsub(/\\/, '\\' => '\\\\').inspect
		puts program_text
		system("echo '#{@@password}' | sudo -S touch #{@@programs_path}/#{self.id}/#{programming_task_id}.cpp")
		system("echo #{program_text} | sudo tee #{@@programs_path}/#{self.id}/#{programming_task_id}.cpp")
		return true
	end

	def get_program programming_task_id
		program_text = ""
		path = "#{@@programs_path}/#{self.id}/#{programming_task_id}.cpp"
		if File.file?(path)
			program_text = File.read(path) || ""
		end
		return program_text
	end

	def check_program! programming_task_id
		require 'fileutils'
		score = 0;
		max_score = 0;
		programming_task = ProgrammingTask.find(programming_task_id)
		test_cases = programming_task.test_cases
		system("echo '#{@@password}' | sudo -S g++ #{@@programs_path}/#{self.id}/#{programming_task_id}.cpp -o #{@@programs_path}/#{self.id}/#{programming_task_id}.out 2>&1 | sudo tee #{@@programs_path}/#{self.id}/compilation_log")
		compilation_log = File.read("#{@@programs_path}/#{self.id}/compilation_log")
		if compilation_log.length == 0
			compilation_log = "Success"
			test_cases.each do |test_case|
				system("echo '#{@@password}' | sudo -S rm #{@@programs_path}/#{self.id}/stdout")
				system("echo '../programs/#{self.id}/#{programming_task_id}.out ../test/input/#{programming_task_id}/#{test_case.input_file_name} ../programs/#{self.id}/stdout' | sudo tee -a #{@@admin_programs_path}/job_queue")
				#system("echo '#{@@password}' | sudo -S cat #{@@programs_path}/#{self.id}/output")
				begin
					unless File.file?("#{@@programs_path}/#{self.id}/stdout")
						raise "File is not created yet"
					end
					if system %Q[lsof #{@@programs_path}/#{self.id}/stdout]
						raise "File is being used by other process(es)" 
					end
					output = File.read("#{@@programs_path}/#{self.id}/stdout").strip
					correct_output = File.read("#{@@test_output_directory}/#{programming_task_id}/#{test_case.output_file_name}").strip
					if output == correct_output
						score = score + test_case.marks
					end
				rescue
					retry
				end
				max_score = max_score + test_case.marks
			end
		end
		self.marks[self.programming_tasks.index(programming_task_id)] = score
		self.save
		return {score: score, max_score: max_score, compilation_log: compilation_log}
	end

	def run_program programming_task_id, stdin
		inspected_stdin = stdin.gsub(/\\/, '\\' => '\\\\').inspect
		stdout = ""
		system("echo '#{@@password}' | sudo -S g++ #{@@programs_path}/#{self.id}/#{programming_task_id}.cpp -o #{@@programs_path}/#{self.id}/#{programming_task_id}.out 2>&1 | sudo tee #{@@programs_path}/#{self.id}/compilation_log")
		system("echo #{inspected_stdin} | sudo tee #{@@programs_path}/#{self.id}/stdin")
		compilation_log = File.read("#{@@programs_path}/#{self.id}/compilation_log")
		if compilation_log.length == 0
			compilation_log = "Success"
			system("echo '#{@@password}' | sudo -S rm #{@@programs_path}/#{self.id}/stdout")
			system("echo '../programs/#{self.id}/#{programming_task_id}.out ../programs/#{self.id}/stdin ../programs/#{self.id}/stdout' | sudo tee -a #{@@admin_programs_path}/job_queue")
			#system("echo '#{@@password}' | sudo -S cat #{@@programs_path}/#{self.id}/output")
			begin
				unless File.file?("#{@@programs_path}/#{self.id}/stdout")
					raise "File is not created yet"
				end
				if system %Q[lsof #{@@programs_path}/#{self.id}/stdout]
					raise "File is being used by other process(es)" 
				end
				stdout = File.read("#{@@programs_path}/#{self.id}/stdout").strip
			rescue
				retry
			end
		end
		return {stdin: stdin, stdout: stdout, compilation_log: compilation_log}
	end

	def self.calculate_result programming_exam_id, cut_off
		retValue = []
		programming_answer_sheets = ProgrammingAnswerSheet.where('programming_exam_id = ?', programming_exam_id)
		programming_answer_sheets.each do |pas|
			score = 0
			pas.marks.each do |mark|
				score = score + mark
			end
			pas.score = score
			pas.save
		end

		if cut_off
			programming_answer_sheets = programming_answer_sheets.where('score >= ?', cut_off)
		end

		programming_answer_sheets.each do |pas|
			user = User.find pas.user_id
			programming_answer_sheet_json = pas.as_json
			user_name = user.first_name + ' '
			user_name = user_name + user.last_name if user.last_name
			programming_answer_sheet_json[:user_name] = user_name
			retValue.push(programming_answer_sheet_json)
		end
		retValue
	end

	def remove
		programming_answer_sheet_id = self.id
		self.destroy
		system("echo '#{@@password}' | sudo -S rm -rf #{@@programs_path}/#{programming_answer_sheet_id}")
		return true
	end

	def self.get_for_users params
		users = User.all
		users = users.where('first_name like ?', params[:first_name] + "%") if params[:first_name] and params[:first_name] != ""
	    users = users.where('email like ?', params[:email] + "%") if params[:email] and params[:email] != ""
	    users = users.where('college_id = ?', params[:college_id] + "%") if params[:college_id] and params[:college_id] != ""
	    user_ids = users.select(:id)

	    programming_answer_sheets = ProgrammingAnswerSheet.where("programming_exam_id = ? and user_id in (?)", params[:programming_exam_id], user_ids)
	end
end
