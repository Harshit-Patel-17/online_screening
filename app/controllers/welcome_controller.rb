class WelcomeController < ApplicationController

	def welcome
		if can? :manage, :site
			redirect_to exams_path
		elsif can? :give, :exam
			redirect_to exams_my_exams_path
		else
			redirect_to new_user_session_path
		end
	end

end