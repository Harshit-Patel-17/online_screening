class AnswerSheetsController < ApplicationController
	respond_to :html, :json

	before_action :authenticate_user!
	before_action :authorize_admin, only: [:index, :destroy]
	before_action :authorize_user, only: [:create, :update]

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: {answerSheets: AnswerSheet.calculate_result(params[:exam_id], params[:cut_off])}}
		end
	end

	def new
	end

	def create
		answer_sheets = AnswerSheet.where('exam_id = ? and user_id = ?', params[:answer_sheet][:exam_id], current_user.id)
		puts answer_sheets
		if answer_sheets.length != 0
			answer_sheet = answer_sheets[0]
			exam = answer_sheet.exam
			if !exam.is_window_open?
				message = "Exam window is not open"
				is_done = false
			elsif answer_sheet.start_test_ip != request.remote_ip
				message = "You cannot resume exam from this IP. Please contact administrator."
				is_done = false
			else
				message = "success"
				is_done = true
			end
		else 
			params[:answer_sheet][:user_id] = current_user.id
			params[:answer_sheet][:start_test_ip] = request.remote_ip
			answer_sheet = AnswerSheet.set params[:answer_sheet]
			message = "success"
			is_done = true
		end
		respond_to do |format|
			format.json { 
				if is_done
					render json: {reply: message, id: answer_sheet.id} 
				else
					render json: {reply: message}
				end
			}
		end
	end

	def edit
	end

	def update
		answersheet = AnswerSheet.find params[:id]
		timer_active = answersheet.end_time >= DateTime.now and answersheet.start_time <= DateTime.now
		user_valid = current_user.id == answersheet.user_id
		ip_correct = answersheet.start_test_ip == request.remote_ip
		if timer_active and user_valid and ip_correct and answersheet.update params[:answer_sheet].symbolize_keys
			message = 'AnswerSheet successfully edited'
		else
			message = 'AnswerSheet modification failed'
		end
		respond_to do |format|
			format.html {}
			format.json {render json: {reply: message}}
		end
	end

	def show
		@answer_sheet = AnswerSheet.find params[:id]
		answer_sheet = @answer_sheet.as_json
		answer_sheet[:currentServerTime] = DateTime.now.utc
		respond_to do |format|
			format.html {}
			format.json { render json: {answerSheet: answer_sheet}}
		end
	end

	def destroy
		answersheet = AnswerSheet.find params[:id]
		if answersheet.delete
			message = "AnswerSheet successfully removed"
		else
			message = "Error in removing AnswerSheet"
		end
		respond_to do |format|
			format.html {render json: {reply: message}}
			format.json {render json: {reply: message}}
		end
	end

	def review
		@answer_sheet = AnswerSheet.find params[:id]
	end

	def time_up
	end

	def change_ip
		respond_to do |format|
			format.html {}
			format.json {
			    answer_sheets = AnswerSheet.get_for_users(params).select(:id, :user_id, :start_test_ip)
			    answer_sheets_with_user = []
			    answer_sheets.each do |as|
			    	answer_sheets_with_user.push(as.attributes.merge(as.user.attributes.except("id")))
			    end
			    render json: {answerSheets: answer_sheets_with_user}
			}
		end
	end

	def update_ip
		answersheet = AnswerSheet.find params[:id]
		answersheet.start_test_ip = params[:start_test_ip]
		answersheet.save
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
