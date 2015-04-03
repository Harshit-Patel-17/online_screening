class User < ActiveRecord::Base
	has_one :privilege
	has_one :role, through: :privilege
	has_many :answer_sheets, :dependent => :delete_all
	
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
