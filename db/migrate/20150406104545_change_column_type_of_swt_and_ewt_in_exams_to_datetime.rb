class ChangeColumnTypeOfSwtAndEwtInExamsToDatetime < ActiveRecord::Migration
  def change
  	change_column :exams, :start_window_time, :datetime
  	change_column :exams, :end_window_time, :datetime
  end
end
