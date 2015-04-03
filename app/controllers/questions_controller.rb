class QuestionsController < ApplicationController
	respond_to :html, :json

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: Question.all}
		end
	end

	def new
	end

	def create
		if Question.set JSON.parse(params[:question]), params[:image]
			message = 'Question successfully created'
		else
			message = 'Question creation failed'
		end
		respond_to do |format|
			format.html {}
			format.json {render json: {reply: message}}
		end
	end

	def edit
	end

	def update
		question = Question.find params[:id]
		if question.edit! JSON.parse(params[:question]), params[:image]
			message = 'Question successfully edited'
		else
			message = 'Question modification failed'
		end
		respond_to do |format|
			format.html {}
			format.json {render json: {reply: message}}
		end
	end

	def show
		question = Question.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: question}
		end
	end

	def destroy
		question = Question.find params[:id]
		if question.remove
			message = "Question successfully removed"
		else
			message = "Error in removing question"
		end
		respond_to do |format|
			format.json {render json: {reply: message}}
		end
	end

	def questions_per_weightage
		qpw = Question.questions_per_weightage
		respond_to do |format|
			format.json {render json: qpw}
		end
	end
end
