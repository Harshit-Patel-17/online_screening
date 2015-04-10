class QuestionCategoriesController < ApplicationController
	respond_to :html, :json

	before_action :authenticate_user!
	before_action :authorize_admin

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: { questionCategories: QuestionCategory.all }}
		end
	end

	def new
	end

	def create
		qc = QuestionCategory.create params[:question_category].symbolize_keys
		if qc
			message = "Question category successfully created"
		else
			message = "Question category creation failed"
		end
		respond_to do |format|
			format.html {
				if qc
					flash[:notice] = message 
					redirect_to question_categories_path
				else
					flash[:alert] = message
					redirect_to new_question_category_path
				end
			}
			format.json {render json: {reply: message, id: qc.id}}
		end
	end

	def edit
		@question_category_id = params[:id]	
	end 

	def update
		qc = QuestionCategory.find(params[:id])
		is_done = qc.update params[:question_category].symbolize_keys
		if is_done
			message = "Question category successfully updated"
		else
			message = "Question category modification failed"
		end
		respond_to do |format|
			format.html { 
				if is_done
					flash[:notice] = message
					redirect_to question_categories_path 
				else
					flash[:alert] = message
					redirect_to edit_question_category_path(qc.id)
				end
			}
			format.json {render json: {reply: message, id: params[:id]}}
		end
	end

	def show
		qc = QuestionCategory.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: {questionCategory: qc}}
		end
	end

	def destroy
		qc = QuestionCategory.find params[:id]
		if qc.delete
			message = "Question category successfully removed"
		else
			message = "Error in removing Question category"
		end
		respond_to do |format|
			format.html {render json: {reply: message}}
			format.json {render json: {reply: message}}
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
