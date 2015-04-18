class ChangeWindowTimeFieldsTypeToDatetimeInProgrammingExam < ActiveRecord::Migration
  def change
  	change_column :programming_exams, :start_window_time, :datetime
  	change_column :programming_exams, :end_window_time, :datetime
  end
end
