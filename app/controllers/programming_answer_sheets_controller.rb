class ProgrammingAnswerSheetsController < ApplicationController
	respond_to :html, :json

	before_action :authenticate_user!
	before_action :authorize_admin, only: [:index, :destroy]
	before_action :authorize_user, only: [:create, :update]

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: {programmingAnswerSheets: ProgrammingAnswerSheet.calculate_result(params[:programming_exam_id], params[:cut_off])}}
		end
	end

	def new
	end

	def create
		programming_answer_sheets = ProgrammingAnswerSheet.where('programming_exam_id = ? and user_id = ?', params[:programming_answer_sheet][:programming_exam_id], current_user.id)
		if programming_answer_sheets.length != 0
			programming_answer_sheet = programming_answer_sheets[0]
			programming_exam = programming_answer_sheet.programming_exam
			if !programming_exam.is_window_open?
				message = "Programming exam window is not open"
				is_done = false
			elsif programming_answer_sheet.start_test_ip != request.remote_ip
				message = "You cannot resume exam from this IP. Please contact administrator."
				is_done = false
			else
				message = "success"
				is_done = true
			end
		else 
			params[:programming_answer_sheet][:user_id] = current_user.id
			params[:programming_answer_sheet][:start_test_ip] = request.remote_ip
			programming_answer_sheet = ProgrammingAnswerSheet.set params[:programming_answer_sheet]
			message = "success"
			is_done = true
		end
		respond_to do |format|
			format.json { 
				if is_done
					render json: {reply: message, id: programming_answer_sheet.id} 
				else
					render json: {reply: message}
				end
			}
		end
	end

	def edit
	end

	def save_program
		programming_answer_sheet = ProgrammingAnswerSheet.find params[:id]
		timer_active = programming_answer_sheet.end_time >= DateTime.now and programming_answer_sheet.start_time <= DateTime.now
		user_valid = current_user.id == programming_answer_sheet.user_id
		ip_correct = programming_answer_sheet.start_test_ip == request.remote_ip
		if timer_active and user_valid and ip_correct and programming_answer_sheet.save_program(params[:programming_task_id], params[:program_text])
			message = 'program successfully saved'
		else
			message = 'Error in saving the program'
		end
		respond_to do |format|
			format.html {}
			format.json {render json: {reply: message}}
		end
	end

	def get_program
		programming_answer_sheet = ProgrammingAnswerSheet.find params[:id]
		timer_active = programming_answer_sheet.end_time >= DateTime.now and programming_answer_sheet.start_time <= DateTime.now
		user_valid = current_user.id == programming_answer_sheet.user_id
		ip_correct = programming_answer_sheet.start_test_ip == request.remote_ip
		if timer_active and user_valid and ip_correct
			program_text = programming_answer_sheet.get_program(params[:programming_task_id])
			message = 'success'
		else
			program_text = ""
			message = 'Request denied'
		end
		respond_to do |format|
			format.html {}
			format.json {render json: {reply: message, programText: program_text}}
		end
	end

	def check_program
		programming_answer_sheet = ProgrammingAnswerSheet.find(params[:id])
		result = programming_answer_sheet.check_program!(params[:programming_task_id])
		respond_to do |format|
			format.json{ render json: result }
		end
	end

	def run_program
		programming_answer_sheet = ProgrammingAnswerSheet.find(params[:id])
		result = programming_answer_sheet.run_program(params[:programming_task_id], params[:stdin])
		respond_to do |format|
			format.json{ render json: result }
		end
	end

	def show
		@programming_answer_sheet = ProgrammingAnswerSheet.find params[:id]
		programming_answer_sheet = @programming_answer_sheet.as_json
		programming_answer_sheet[:currentServerTime] = DateTime.now.utc
		programming_answer_sheet[:task_names] = @programming_answer_sheet.get_task_names
		respond_to do |format|
			format.html {}
			format.json { render json: {programmingAnswerSheet: programming_answer_sheet}}
		end
	end

	def destroy
		programming_answer_sheet = ProgrammingAnswerSheet.find params[:id]
		if programming_answer_sheet.remove
			message = "Programming Answer Sheet successfully removed"
		else
			message = "Error in removing Programming Answer Sheet"
		end
		respond_to do |format|
			format.html {render json: {reply: message}}
			format.json {render json: {reply: message}}
		end
	end

	def time_up
	end

	def change_ip
		respond_to do |format|
			format.html {}
			format.json {
			    programming_answer_sheets = ProgrammingAnswerSheet.get_for_users(params).select(:id, :user_id, :start_test_ip)
			    programming_answer_sheets_with_user = []
			    programming_answer_sheets.each do |pas|
			    	programming_answer_sheets_with_user.push(pas.attributes.merge(pas.user.attributes.except("id")))
			    end
			    render json: {programmingAnswerSheets: programming_answer_sheets_with_user}
			}
		end
	end

	def update_ip
		programming_answer_sheet = ProgrammingAnswerSheet.find params[:id]
		programming_answer_sheet.start_test_ip = params[:start_test_ip]
		programming_answer_sheet.save
		respond_to do |format|
			format.json { render json: {reply: "success"}}
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
