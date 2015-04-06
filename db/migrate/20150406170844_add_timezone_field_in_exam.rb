class AddTimezoneFieldInExam < ActiveRecord::Migration
  def change
  	add_column :exams, :timezone, :string
  end
end
