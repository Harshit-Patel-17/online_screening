class CreateProgrammingAnswerSheets < ActiveRecord::Migration
  def change
    create_table :programming_answer_sheets do |t|
    	t.references  :programming_exam, index: true
	    t.references	:user, index: true
	    t.text     :programming_tasks
	    t.text     :marks
	    t.integer  :score
	    t.datetime :start_time
	    t.string   :start_test_ip
	    t.datetime :end_time
      t.timestamps null: false
    end
    add_foreign_key :programming_answer_sheets, :programming_exams
    add_foreign_key :programming_answer_sheets, :users
  end
end
