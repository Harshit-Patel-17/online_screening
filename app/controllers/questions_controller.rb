class QuestionsController < ApplicationController
	respond_to :html, :json

	def index
		respond_to do |format|
			format.html {}
			format.json {
				question = Question.select(:id, :question, :weightage)
				question = question.offset(params[:offset].to_i) if params.has_key? :offset
				question = question.limit(params[:limit].to_i) if params.has_key? :limit
				render json: { questions: question }
			}
		end
	end

	def new
	end

	def create
		q = Question.set params[:question].symbolize_keys, params[:image]
		if q
			message = 'Question successfully created'
		else
			message = 'Question creation failed'
		end
		respond_to do |format|
			format.html { redirect_to question_path(q.id) }
			format.json { render json: {reply: message, id: q.id} }
		end
	end

	def edit
	end

	def update
		question = Question.find params[:id]
		if question.edit! params[:question].symbolize_keys, params[:image]
			message = 'Question successfully edited'
		else
			message = 'Question modification failed'
		end
		respond_to do |format|
			format.html { redirect_to question_path(params[:id]) }
			format.json {render json: {reply: message, id: params[:id]}}
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
			format.html {render json: {qpw: qpw}}
			format.json {render json: {qpw: qpw}}
		end
	end
end
