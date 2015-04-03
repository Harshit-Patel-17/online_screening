class CreateAnswerSheets < ActiveRecord::Migration
  def change
    create_table :answer_sheets do |t|
    	t.references :exam, index: true
    	t.references :user, index: true
    	t.text     :questions
	    t.text     :answers
	    t.integer  :score
	    t.datetime :start_time
	    t.string   :start_test_ip
      t.timestamps null: false
    end
    add_foreign_key :answer_sheets, :exams
    add_foreign_key :answer_sheets, :users
  end
end
