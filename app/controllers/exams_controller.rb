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
		e = Exam.new(JSON.parse(params[:exam]))
		if e.save
			message = "Exam successfully created"
		else
			message = "Exam creation failed"
		end
		respond_to do |format|
			format.html {}
			format.json {render json: {reply: message}}
		end
	end

	def edit	
	end 

	def update
		e = Exam.find(params[:id])
		if e.update(JSON.parse(params[:exam]))
			message = "Exam successfully updated"
		else
			message = "Exam modification failed"
		end
		respond_to do |format|
			format.html {}
			format.json {render json: {reply: message}}
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
			format.json {render json: {reply: message}}
		end
	end

	def set_test
		respond_to do |format|
			format.html {}
			format.json {
				exam = Exam.find params[:id]
				if exam.set_test! JSON.parse(params[:test])
					message = "Test has been set successfully"
				else
					message = "Error in setting test"
				end
				render json: {reply: message}
			}
		end
	end

	def select_questions
		respond_to do |format|
			format.json {
				questions = Question.get_for_exam params[:id]
				render json: questions
			}
		end
	end

	def set_questions
		exam = Exam.find params[:id]
		if exam.set_questions JSON.parse(params[:question_ids])
			message = "Questions successfully set"
		else
			message = "Questions could not be set"
		end
		respond_to do |format|
			format.json {render json: {reply: message}}
		end
	end
end
