class ApplicationMailer < ActionMailer::Base
  default from: "harshit.patel@infibeam.net"
  
  def send_credentials_to_student(email, password)
  	@password = password
  	attachments['logo'] = File.read('app/assets/images/infibeam-logo.png')
  	mail(:to => email,
  		 :subject => "Login credentials for Infibeam online screening test")
  end

  def send_credentials_to_admin(email, password)
  	@password = password
  	attachments['logo'] = File.read('app/assets/images/infibeam-logo.png')
  	mail(:to => email,
  		 :subject => "Login credentials for Infibeam online screening")
  end
end
