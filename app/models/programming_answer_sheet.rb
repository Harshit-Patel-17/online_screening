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
	@@languages = ["c++", "java"]
	@@extensions = {"c++" => "cpp", "java" => "java"}
	@@target_extensions = {"c++" => "out", "java" => "class"}

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
		@@languages.each do |lang|
			system("echo '#{@@password}' | sudo -S mkdir #{@@programs_path}/#{pas.id}/#{lang}")
			system("echo '#{@@password}' | sudo -S touch #{@@programs_path}/#{pas.id}/#{lang}/stdout")
			system("echo '#{@@password}' | sudo -S touch #{@@programs_path}/#{pas.id}/#{lang}/stdin")
			system("echo '#{@@password}' | sudo -S touch #{@@programs_path}/#{pas.id}/#{lang}/stderr")
		end

		return pas
	end

	def get_task_names
		retVal = []
		self.programming_tasks.each do |programming_task_id|
			retVal.push(ProgrammingTask.find(programming_task_id).task_name)
		end
		return retVal
	end

	def save_program programming_task_id, program_text, lang
		program_text = program_text.strip.gsub(/\\/, '\\' => '\\\\').inspect
		puts program_text
		system("echo '#{@@password}' | sudo -S touch #{@@programs_path}/#{self.id}/#{lang}/#{programming_task_id}.#{@@extensions[lang]}")
		system("echo #{program_text} | sudo tee #{@@programs_path}/#{self.id}/#{lang}/#{programming_task_id}.#{@@extensions[lang]}")
		return true
	end

	def get_program programming_task_id, lang
		program_text = ""
		path = "#{@@programs_path}/#{self.id}/#{lang}/#{programming_task_id}.#{@@extensions[lang]}"
		if File.file?(path)
			program_text = File.read(path) || ""
		end
		return program_text
	end

	def check_program! programming_task_id, input, lang
		require 'fileutils'
		score = 0;
		max_score = 0;
		programming_task = ProgrammingTask.find(programming_task_id)
		test_cases = programming_task.test_cases
		compilation_log = compile_program(programming_task_id, lang)
		if compilation_log.length == 0
			compilation_log = "Success"
			test_cases.each do |test_case|
				system("echo '#{@@password}' | sudo -S rm #{@@programs_path}/#{self.id}/#{lang}/stdout")
				input_file = "../test/input/#{programming_task_id}/#{test_case.input_file_name}"
				output_file = "../programs/#{self.id}/#{lang}/stdout"
				error_file = "../programs/#{self.id}/#{lang}/stderr"
				enqueue_program_for_execution(programming_task_id, lang, input_file, output_file, input)
				#system("echo '../programs/#{self.id}/#{lang}/#{programming_task_id}.out ../test/input/#{programming_task_id}/#{test_case.input_file_name} ../programs/#{self.id}/#{lang}/stdout' | sudo tee -a #{@@admin_programs_path}/job_queue")
				#system("echo '#{@@password}' | sudo -S cat #{@@programs_path}/#{self.id}/output")
				begin
					unless File.file?("#{@@programs_path}/#{self.id}/#{lang}/stdout")
						raise "File is not created yet"
					end
					if system %Q[lsof #{@@programs_path}/#{self.id}/#{lang}/stdout]
						raise "File is being used by other process(es)" 
					end
					output = File.read("#{@@programs_path}/#{self.id}/#{lang}/stdout").strip
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

	def run_program programming_task_id, input, lang
		stdin = input[:stdin] || ""
		inspected_stdin = stdin.gsub(/\\/, '\\' => '\\\\').inspect
		stdout = ""
		system("echo #{inspected_stdin} | sudo tee #{@@programs_path}/#{self.id}/#{lang}/stdin")
		compilation_log = compile_program(programming_task_id, lang)
		if compilation_log.length == 0
			compilation_log = "Success"
			system("echo '#{@@password}' | sudo -S rm #{@@programs_path}/#{self.id}/#{lang}/stdout")
			input_file = "../programs/#{self.id}/#{lang}/stdin"
			output_file = "../programs/#{self.id}/#{lang}/stdout"
			error_file = "../programs/#{self.id}/#{lang}/stderr"
			enqueue_program_for_execution(programming_task_id, lang, input_file, output_file, error_file, input)
			#system("echo '#{@@password}' | sudo -S cat #{@@programs_path}/#{self.id}/output")
			begin
				unless File.file?("#{@@programs_path}/#{self.id}/#{lang}/stdout")
					raise "File is not created yet"
				end
				if system %Q[lsof #{@@programs_path}/#{self.id}/#{lang}/stdout]
					raise "File is being used by other process(es)" 
				end
				stdout = File.read("#{@@programs_path}/#{self.id}/#{lang}/stdout").strip
				stderr = File.read("#{@@programs_path}/#{self.id}/#{lang}/stderr").strip
			rescue
				retry
			end
		end
		remove_target_code_files(lang)
		return {stdin: stdin, stdout: stdout, stderr: stderr, compilation_log: compilation_log}
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

	def compile_program programming_task_id, lang
		if lang == 'c++'
			system("echo '#{@@password}' | sudo -S g++ #{@@programs_path}/#{self.id}/#{lang}/#{programming_task_id}.#{@@extensions[lang]} -o #{@@programs_path}/#{self.id}/#{lang}/#{programming_task_id}.out 2>&1 | sudo tee #{@@programs_path}/#{self.id}/#{lang}/compilation_log")
		elsif lang == 'java'
			system("echo '#{@@password}' | sudo -S javac #{@@programs_path}/#{self.id}/#{lang}/#{programming_task_id}.#{@@extensions[lang]} 2>&1 | sudo tee #{@@programs_path}/#{self.id}/#{lang}/compilation_log")
		end
		compilation_log = File.read("#{@@programs_path}/#{self.id}/#{lang}/compilation_log")
		return compilation_log
	end

	def enqueue_program_for_execution programming_task_id, lang, input_file, output_file, error_file, input
		if lang == 'c++'
			system("echo '../programs/#{self.id}/#{lang}/#{programming_task_id}.out #{input_file} #{output_file} #{error_file}' | sudo tee -a #{@@admin_programs_path}/job_queue")
		elsif lang == 'java'
			puts input[:class]
			system("echo '/usr/bin/java -cp ../programs/#{self.id}/#{lang}/ #{input[:class]} #{input_file} #{output_file}' | sudo tee -a #{@@admin_programs_path}/job_queue")
		end
	end

	def remove_target_code_files lang
		system("echo '#{@@password}' | sudo -S rm #{@@programs_path}/#{self.id}/#{lang}/*.#{@@target_extensions[lang]}")
	end
end
