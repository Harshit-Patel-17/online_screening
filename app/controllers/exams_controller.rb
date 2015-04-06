class ExamsController < ApplicationController
	respond_to :html, :json

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: { exams: Exam.all }}
		end
	end

	def new
	end

	def create
		exam = Exam.set params[:exam]
		if exam
			message = "Exam successfully created"
		else
			message = "Exam creation failed"
		end
		respond_to do |format|
			format.html {
				if exam
					flash[:notice] = message 
					redirect_to "/exams/" + exam.id.to_s + "/scheme" 
				else
					flash[:alert] = message
					redirect_to new_exam_path()
				end
			}
			format.json {render json: {reply: message, id: exam.id}}
		end
	end

	def edit
		@exam_id = params[:id]	
	end 

	def update
		e = Exam.find(params[:id])
		is_done = e.update params[:exam].symbolize_keys
		if is_done
			message = "Exam successfully updated"
		else
			message = "Exam modification failed"
		end
		respond_to do |format|
			format.html { 
				if is_done
					flash[:notice] = message
					redirect_to exam_path(e.id) 
				else
					flash[:alert] = message
					redirect_to edit_exam_path(e.id)
				end
			}
			format.json {render json: {reply: message, id: params[:id]}}
		end
	end

	def show
		exam = Exam.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: {exam: exam}}
		end
	end

	def destroy
		exam = Exam.find params[:id]
		if exam.delete
			message = "Exam successfully removed"
		else
			message = "Error in removing exam"
		end
		respond_to do |format|
			format.html {render json: {reply: message}}
			format.json {render json: {reply: message}}
		end
	end

	def show_scheme
		@exam = Exam.find params[:id]
		respond_to do |format|
			format.html {}
			format.json { render json: {scheme: @exam.get_question_count_per_weightage}}
		end
	end

	def set_scheme
		exam = Exam.find params[:id]
		is_done = exam.set_scheme! params[:scheme]
		if is_done
			message = "Test has been set successfully"
		else
			message = "Error in setting test"
		end
		respond_to do |format|
			format.html { 
				if is_done
					flash[:notice] = message
					redirect_to "/exams/" + params[:id] + "/questions"
				else
					flash[:alert] = message
					redirect_to "/exams/" + params[:id] + "/scheme"
				end 
			}
			format.json { render json: {reply: message}}
		end
	end

	def select_questions
		@exam = Exam.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {
				questions = Question.get_for_exam params[:id]
				render json: {questions: questions.select(:id, :question, :weightage)}
			}
		end
	end

	def set_questions
		exam = Exam.find params[:id]
		is_done = exam.set_questions params[:question_ids]
		if is_done
			message = "Questions successfully set"
		else
			message = "Questions could not be set"
		end
		respond_to do |format|
			format.html {
				if is_done
					flash[:notice] = message
					url = "/exams/" + params[:id] + "/questions" if is_done
				else
					flash[:alert] = message
					url = "/exams/" + params[:id] + "/questions" unless is_done
				end
				redirect_to url
			}
			format.json {render json: {reply: message}}
		end
	end

	def select_colleges
		@exam = Exam.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {
				colleges = College.all
				render json: {colleges: colleges}
			}
		end
	end

	def set_colleges
		exam = Exam.find params[:id]
		is_done = exam.set_colleges params[:college_ids]
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
				redirect_to exams_path
			}
			format.json {render json: {reply: message}}
		end
	end

	def my_exams
		my_exams = Exam.get_for_user current_user.id
		respond_to do |format|
			format.html {}
			format.json {
				render json: {myExams: my_exams}
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
end
