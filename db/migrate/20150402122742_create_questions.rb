class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
		  t.text     :question
	    t.text	   :options
	    t.string   :answers
	    t.integer  :weightage
	    t.string   :qtype
	    t.integer  :no_of_options
	    t.string   :image
	    t.integer  :question_appeared_count, default: 0
	    t.integer  :correct_response_count, default: 0
      t.timestamps null: false
    end
  end
end
