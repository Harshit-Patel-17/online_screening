class User < ActiveRecord::Base
	has_one :privilege, :dependent => :delete
	has_one :role, through: :privilege
	has_many :answer_sheets, :dependent => :delete_all
	belongs_to :college
	
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.create_admin admin
    return false unless admin and admin[:first_name] and admin[:email]
    begin
      EmailVerifier.check(admin[:email])
    rescue Exception => error
      return false
    end
    admin[:password] = Digest::MD5.hexdigest(Time.now.to_s)[0..9]
    user = User.new
    user.first_name = admin[:first_name]
    user.last_name = admin[:last_name] if admin[:last_name]
    user.email = admin[:email]
    user.password = admin[:password]
    user.save
    admin_role_id = Role.find_by_role_name('admin').id
    privilege = Privilege.new
    privilege.user_id = user.id
    privilege.role_id = admin_role_id
    privilege.save
    ApplicationMailer.send_credentials_to_admin(admin[:email], admin[:password]).deliver_now
    user
  end

  def self.classify_by_roles
    users = User.select(:id, :first_name, :last_name, :email, :college_id)
    retVal = Hash.new
    retVal[:admins] = []
    retVal[:users] = []
    users.each do |user|
      if user.role.role_name == 'admin'
        retVal[:admins].push(user)
      else
        retVal[:users].push(user)
      end
    end
    return retVal
  end

  def self.get_non_admins params
    user_role_id = Role.find_by_role_name('user').id
    user_ids = Privilege.where('role_id = ?', user_role_id).select(:user_id)
    users = User.where('id in (?)', user_ids)
    users = users.where('first_name like ?', params[:first_name] + "%") if params[:first_name] and params[:first_name] != ""
    users = users.where('email like ?', params[:email] + "%") if params[:email] and params[:email] != ""
    users = users.where('college_id = ?', params[:college_id] + "%") if params[:college_id] and params[:college_id] != ""
    users = users.offset(params[:offset]) if params[:offset]
    users = users.limit(params[:limit]) if params[:limit]
    users
  end

  def self.get_admins
    admin_role_id = Role.find_by_role_name('admin').id
    admin_ids = Privilege.where('role_id = ?', admin_role_id).select(:user_id)
    admins = User.where('id in (?)', admin_ids)
    admins.select(:id, :first_name, :email)
  end

  def self.mass_create users
  	require 'spreadsheet'
    require 'digest/md5'

  	users_file = users
    extension = File.extname(users_file.original_filename)
    unless extension == '.xls'
      flash[:alert] = "Please select .xls file"
      redirect_to users_mass_new()
    end

    file_name = '(' + Time.now.to_s + ')' + users_file.original_filename
    directory = 'public/spreadsheets'
    path = File.join(directory, file_name)
    File.open(path, "wb"){|f| f.write(users_file.read)}
    workbook = Spreadsheet.open(path)
    sheet = workbook.worksheet('Sheet1')

    sheet[0,9] = 'generated_password'
    sheet[0,10] = 'user_registration_status'
    users_registered = []
    users_not_registered = []

    user_role_id = Role.find_by_role_name('user').id

    sheet.each 1 do |row|
      user = Hash.new
      user = {
        college_id: row[0],
        student_id: row[1],
        first_name: row[2],
        last_name: row[3],
        email: row[4],
        phone_no: row[5],
        degree: row[6],
        passing_year: row[7],
        date_of_birth: row[8]
      }
      begin
        EmailVerifier.check(user[:email])
        password = Digest::MD5.hexdigest(user[:date_of_birth].to_s + Time.now.to_s)[0..9]
        user[:password] = password
        user_rec = User.create(user)
        if user_rec.valid?
          users_registered.push(user)
          previlege = Privilege.new
          previlege.user_id = user_rec.id
          previlege.role_id = user_role_id
          previlege.save
          ApplicationMailer.send_credentials_to_student(user[:email], user[:password]).deliver_now
          row[9] = password
          row[10] = "Success"
        else
          user[:reason] = "User already exist"
          users_not_registered.push(user)
          row[10] = "Failed"
        end
      rescue Exception => error
        user[:reason] = error.message
        users_not_registered.push(user)
        row[10] = "Failed"
      end
    end
    workbook.write path
    return {
      usersRegistered: users_registered, 
      usersNotRegistered: users_not_registered
      }
  end
end
