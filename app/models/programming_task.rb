class ProgrammingTask < ActiveRecord::Base
	has_many :test_cases, :dependent => :delete_all
	has_many :programming_exam_tasks
	has_many :programming_exams, :through => :programming_exam_tasks

	@@sandbox_path = "/sandbox"
	@@test_input_directory = @@sandbox_path + "/test/input"
	@@test_output_directory = @@sandbox_path + "/test/output"
	@@password = "infibeam"

	def self.set programming_task, test_inputs, test_outputs, test_marks
		pt = ProgrammingTask.create(programming_task.symbolize_keys)
		system("echo '#{@@password}' | sudo -S mkdir #{@@test_input_directory}/#{pt.id}")
		system("echo '#{@@password}' | sudo -S mkdir #{@@test_output_directory}/#{pt.id}")
		test_cases_count = test_inputs.length
		for i in 0..test_cases_count-1
			file_name = i.to_s
			test_input = test_inputs[i].read.gsub(/\\/, '\\' => '\\\\').inspect
			test_output = test_outputs[i].read.gsub(/\\/, '\\' => '\\\\').inspect
			test_mark = test_marks[i]
			system("echo '#{@@password}' | sudo -S touch #{@@test_input_directory}/#{pt.id}/#{file_name}")
			system("echo #{test_input} | sudo tee #{@@test_input_directory}/#{pt.id}/#{file_name}")
			system("echo '#{@@password}' | sudo -S touch #{@@test_output_directory}/#{pt.id}/#{file_name}")
			system("echo #{test_output} | sudo tee #{@@test_output_directory}/#{pt.id}/#{file_name}")
			tc = TestCase.new
			tc.programming_task_id = pt.id
			tc.input_file_name = file_name
			tc.output_file_name = file_name
			tc.marks = test_mark
			tc.save
		end
		return pt
	end

	def self.remove programming_task_id
		programming_task = ProgrammingTask.find(programming_task_id)
		programming_task.destroy
		system("echo '#{@@password}' | sudo -S rm -rf #{@@test_input_directory}/#{programming_task_id}")
		system("echo '#{@@password}' | sudo -S rm -rf #{@@test_output_directory}/#{programming_task_id}")
	end
end
