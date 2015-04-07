class AnswerSheetsController < ApplicationController
	respond_to :html, :json

	before_action :authorize_admin, only: [:index, :destroy]
	before_action :authorize_user, except: [:index, :destroy]

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: {answerSheets: AnswerSheet.calculate_result(params[:exam_id], params[:cut_off])}}
		end
	end

	def new
	end

	def create
		params[:answer_sheet][:user_id] = current_user.id
		params[:answer_sheet][:start_test_ip] = request.remote_ip
		answer_sheet = AnswerSheet.set params[:answer_sheet]
		if answer_sheet
			message = 'AnswerSheet successfully created'
		else
			message = 'AnswerSheet creation failed'
		end
		respond_to do |format|
			format.html {
				if answer_sheet
					if answer_sheet.end_time >= Time.now
						redirect_to answer_sheet_path(answer_sheet.id)
					else
						redirect_to "/answer_sheets/time_up"
					end
				else
					redirect_to "/exams/my_exams"
				end
			}
			format.json {
				render json: {reply: message, id: answer_sheet.id}
			}
		end
	end

	def edit
	end

	def update
		answersheet = AnswerSheet.find params[:id]
		timer_active = answersheet.end_time >= DateTime.now and answersheet.start_time <= DateTime.now
		if timer_active and answersheet.update params[:answer_sheet].symbolize_keys
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
		respond_to do |format|
			format.html {}
			format.json {render json: {answerSheet: @answer_sheet}}
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

	def time_up
	end

	private

	def authorize_admin
		authorize! :manage, :site, :message => "Only admin can access this url."
	end

	def authorize_user
		authorize! :give, :exam, :message => "Log in as student to access this url."
	end
end
