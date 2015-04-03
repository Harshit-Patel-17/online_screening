class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
    	t.integer  :duration_mins
	    t.string   :college_name
	    t.string   :exam_name
	    t.date     :date
	    t.time     :time
	    t.text   	 :question_count_per_weightage
	    t.integer  :total_marks
	    t.string   :status
	    t.time     :start_window_time
	    t.time     :end_window_time
      t.timestamps null: false
    end
  end
end
