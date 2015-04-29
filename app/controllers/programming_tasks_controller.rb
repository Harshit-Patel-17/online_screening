class ProgrammingTasksController < ApplicationController
	respond_to :html, :json

	before_action :authenticate_user!
	before_action :authorize_admin, except: [:show]

	def index
		@programming_tasks = ProgrammingTask.all
		respond_to do |format|
			format.html {}
			format.json { render json: {programmingTasks: @programming_tasks}}
		end
	end

	def new
	end

	def create
		respond_to do |format|
			format.json {
				programming_task = ProgrammingTask.set(params[:programming_task], params[:test_inputs], params[:test_outputs], params[:test_marks])
				redirect_to programming_tasks_path
			}
		end
	end

	def edit
		@exam_id = params[:id]	
	end 

	def update
		respond_to do |format|
			format.html {}
			format.json {}
		end
	end

	def show
		@programming_task = ProgrammingTask.find params[:id]
		respond_to do |format|
			format.html {}
			format.json { render json:{programmingTask: @programming_task}}
		end
	end

	def destroy
		removed = ProgrammingTask.remove params[:id]
		if removed
			message = "Exam successfully removed"
		else
			message = "Error in removing exam"
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
