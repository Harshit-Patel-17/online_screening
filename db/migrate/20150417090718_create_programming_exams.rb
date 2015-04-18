class CreateProgrammingExams < ActiveRecord::Migration
  def change
    create_table :programming_exams do |t|
    	t.integer  :duration_mins
	    t.string   :exam_name
	    t.text     :programming_tasks
	    t.integer  :total_marks
	    t.time     :start_window_time
	    t.time     :end_window_time
      t.timestamps null: false
    end
  end
end
