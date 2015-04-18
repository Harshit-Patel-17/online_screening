class CreateProgrammingExamColleges < ActiveRecord::Migration
  def change
    create_table :programming_exam_colleges do |t|
    	t.references :programming_exam, index: true
      t.references :college, index: true
      t.timestamps null: false
    end
    add_foreign_key :programming_exam_colleges, :programming_exams
    add_foreign_key :programming_exam_colleges, :colleges
  end
end
