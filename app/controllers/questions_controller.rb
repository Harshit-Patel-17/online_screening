class QuestionsController < ApplicationController
	respond_to :html, :json

	before_action :authorize_admin, except: [:show_without_answers]

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
		question = Question.set params[:question], params[:image]
		if question
			message = 'Question successfully created'
		else
			message = 'Question creation failed'
		end
		respond_to do |format|
			format.html { 
				if question
					flash[:notice] = message
					redirect_to question_path(question.id)
				else
					flash[:alert] = message
					redirect_to new_question_path()
				end
			}
			format.json { render json: {reply: message, id: question.id} }
		end
	end

	def edit
		@question_id = params[:id]
	end

	def update
		question = Question.find params[:id]
		is_done = question.edit! params[:question], params[:image]
		if is_done
			message = 'Question successfully edited'
		else
			message = 'Question modification failed'
		end
		respond_to do |format|
			format.html { 
				if is_done
					flash[:notice] = message
					redirect_to question_path(params[:id]) 
				else
					flash[:alert] = message
					redirect_to edit_question_path(params[:id])
				end
				}
			format.json {render json: {reply: message, id: params[:id]}}
		end
	end

	def show
		question = Question.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: {question: question.as_json}}
		end
	end

	def show_without_answers
		question = Question.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: {question: question.as_json.except!("answers")}}
		end
	end

	def destroy
		question = Question.find params[:id]
		is_done = question.remove
		if is_done
			message = "Question successfully removed"
		else
			message = "Error in removing question"
		end
		respond_to do |format|
			format.html {render json: {reply: message}}
			format.json {render json: {reply: message}}
		end
	end

	def questions_per_weightage
		qpw = Question.questions_per_weightage params[:question_category_id]
		respond_to do |format|
			format.html {render json: {qpw: qpw}}
			format.json {render json: {qpw: qpw}}
		end
	end

	private

	def authorize_admin
		authorize! :manage, :site, :message => "Only admin can access this url."
	end

end
