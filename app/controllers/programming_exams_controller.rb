class ProgrammingExamsController < ApplicationController
	respond_to :html, :json

	before_action :authenticate_user!
	before_action :authorize_admin, except: [:my_exams]
	before_action :authorize_user, only: [:my_exams]

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: { programming_exams: ProgrammingExam.all, current_server_time: DateTime.now.utc }}
		end
	end

	def new
	end

	def create
		programming_exam = ProgrammingExam.create params[:programming_exam].symbolize_keys
		if programming_exam
			message = "Programming exam successfully created"
		else
			message = "Programming exam creation failed"
		end
		respond_to do |format|
			format.html {
				if programming_exam
					flash[:notice] = message 
					redirect_to "/programming_exams/" + programming_exam.id.to_s + "/programming_tasks" 
				else
					flash[:alert] = message
					redirect_to new_programming_exam_path()
				end
			}
			format.json {render json: {reply: message, id: programming_exam.id}}
		end
	end

	def edit
		@programming_exam_id = params[:id]	
	end 

	def update
		pe = ProgrammingExam.find(params[:id])
		is_done = pe.update params[:programming_exam].symbolize_keys
		if is_done
			message = "Programming exam successfully updated"
		else
			message = "Programming exam modification failed"
		end
		respond_to do |format|
			format.html { 
				if is_done
					flash[:notice] = message
					redirect_to programming_exam_path(pe.id) 
				else
					flash[:alert] = message
					redirect_to edit_programming_exam_path(pe.id)
				end
			}
			format.json {render json: {reply: message, id: params[:id]}}
		end
	end

	def show
		@programming_exam = ProgrammingExam.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: {programming_exam: @programming_exam}}
		end
	end

	def destroy
		programming_exam = ProgrammingExam.find params[:id]
		if programming_exam.destroy
			message = "Programming exam successfully removed"
		else
			message = "Error in removing programming exam"
		end
		respond_to do |format|
			format.html {render json: {reply: message}}
			format.json {render json: {reply: message}}
		end
	end

	def select_programming_tasks
		@programming_exam = ProgrammingExam.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {
				programming_tasks = ProgrammingTask.all
				selected_programming_tasks = @programming_exam.get_programming_task_ids
				render json: {
					programming_tasks: programming_tasks,
					selected_programming_tasks: selected_programming_tasks
				}
			}
		end
	end

	def set_programming_tasks
		programming_exam = ProgrammingExam.find params[:id]
		is_done = programming_exam.set_programming_tasks params[:programming_task_ids]
		if is_done
			message = "Programming tasks successfully set"
		else
			message = "Programming tasks could not be set"
		end
		respond_to do |format|
			format.html {
				if is_done
					flash[:notice] = message
					url = "/programming_exams/" + params[:id] + "/colleges"
				else
					flash[:alert] = message
					url = "/programming_exams/" + params[:id] + "/programming_tasks"
				end
				redirect_to url
			}
			format.json {render json: {reply: message}}
		end
	end

	def select_colleges
		@programming_exam = ProgrammingExam.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {
				colleges = College.all
				selected_colleges = ProgrammingExamCollege.get_for_programming_exam params[:id]
				render json: {
					colleges: colleges,
					selected_colleges: selected_colleges
				}
			}
		end
	end

	def set_colleges
		programming_exam = ProgrammingExam.find params[:id]
		is_done = programming_exam.set_colleges params[:college_ids]
		if is_done
			message = "Colleges successfully set"
		else
			message = "Colleges could not be set"
		end
		respond_to do |format|
			format.html {
				if is_done
					flash[:notice] = message
				else
					flash[:alert] = message
				end
				redirect_to programming_exams_path
			}
			format.json {render json: {reply: message}}
		end
	end

	def my_exams
		my_exams = ProgrammingExam.get_for_user current_user.id
		current_server_time = DateTime.now.utc
		respond_to do |format|
			format.html {}
			format.json {
				render json: {myExams: my_exams, currentServerTime: current_server_time}
			}
		end
	end

	def timezones
		timezones = []
		ActiveSupport::TimeZone.all.each do |timezone|
			tz = Hash.new
			tz[:timezone] = timezone.to_s
			tz[:utc_offset] = timezone.utc_offset
			timezones.push(tz)
		end
		respond_to do |format|
			format.json {render json: {timezones: timezones}}
		end
	end

	private

	def authorize_admin
		authorize! :manage, :site, :message => "Only admin can access this url."
	end

	def authorize_user
		authorize! :give, :exam, :message => "Log in as student to access this url."
	end
end
