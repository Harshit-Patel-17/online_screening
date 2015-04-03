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
		e = Exam.new params[:exam].symbolize_keys
		e.status = 'inactive'
		if e.save
			message = "Exam successfully created"
		else
			message = "Exam creation failed"
		end
		respond_to do |format|
			format.html { redirect_to exam_path(e.id) }
			format.json {render json: {reply: message, id: e.id}}
		end
	end

	def edit	
	end 

	def update
		e = Exam.find(params[:id])
		if e.update params[:exam].symbolize_keys
			message = "Exam successfully updated"
		else
			message = "Exam modification failed"
		end
		respond_to do |format|
			format.html { redirect_to exam_path(e.id) }
			format.json {render json: {reply: message, id: params[:id]}}
		end
	end

	def show
		exam = Exam.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: exam}
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
		if exam.set_scheme! params[:scheme]
			message = "Test has been set successfully"
		else
			message = "Error in setting test"
		end
		respond_to do |format|
			format.html { redirect_to "/exams/" + params[:id] + "/questions" }
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
		if exam.set_questions params[:question_ids]
			message = "Questions successfully set"
		else
			message = "Questions could not be set"
		end
		respond_to do |format|
			format.json {render json: {reply: message}}
		end
	end
end
