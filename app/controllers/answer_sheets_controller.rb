class AnswerSheetsController < ApplicationController
	respond_to :html, :json

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: AnswerSheet.all}
		end
	end

	def new
	end

	def create
		if AnswerSheet.set JSON.parse(params[:answer_sheet])
			message = 'AnswerSheet successfully created'
		else
			message = 'AnswerSheet creation failed'
		end
		respond_to do |format|
			format.html {}
			format.json {render json: {reply: message}}
		end
	end

	def edit
	end

	def update
		answersheet = AnswerSheet.find params[:id]
		if answersheet.update JSON.parse(params[:answer_sheet])
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
		answersheet = AnswerSheet.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: answersheet}
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
			format.json {render json: {reply: message}}
		end
	end
end
