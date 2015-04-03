class CreateExamQuestions < ActiveRecord::Migration
  def change
    create_table :exam_questions do |t|
    	t.references :exam, index: true
      t.references :question, index: true
      t.timestamps null: false
    end
    add_foreign_key :exam_questions, :exams
    add_foreign_key :exam_questions, :questions
  end
end
