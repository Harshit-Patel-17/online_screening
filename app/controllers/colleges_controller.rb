class CollegesController < ApplicationController
	respond_to :html, :json

	before_action :authenticate_user!
	before_action :authorize_admin

	def index
		respond_to do |format|
			format.html {}
			format.json {render json: { colleges: College.all }}
		end
	end

	def new
	end

	def create
		college = College.new params[:college].symbolize_keys
		college.save
		if college
			message = "College successfully created"
		else
			message = "College creation failed"
		end
		respond_to do |format|
			format.html {
				if college
					flash[:notice] = message 
					redirect_to college_path(college.id)
				else
					flash[:alert] = message
					redirect_to new_college_path()
				end
			}
			format.json {render json: {reply: message, id: college.id}}
		end
	end

	def edit
		@college_id = params[:id]	
	end 

	def update
		c = College.find(params[:id])
		is_done = c.update params[:college].symbolize_keys
		if is_done
			message = "College successfully updated"
		else
			message = "College modification failed"
		end
		respond_to do |format|
			format.html { 
				if is_done
					flash[:notice] = message
					redirect_to college_path(c.id) 
				else
					flash[:alert] = message
					redirect_to edit_college_path(c.id)
				end
			}
			format.json {render json: {reply: message, id: params[:id]}}
		end
	end

	def show
		college = College.find params[:id]
		respond_to do |format|
			format.html {}
			format.json {render json: {college: college}}
		end
	end

	def destroy
		college = College.find params[:id]
		if college.delete
			message = "College successfully removed"
		else
			message = "Error in removing College"
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
end
