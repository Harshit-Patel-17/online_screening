class CreateProgrammingExamTasks < ActiveRecord::Migration
  def change
    create_table :programming_exam_tasks do |t|
    	t.references :programming_exam, index: true
      t.references :programming_task, index: true
      t.timestamps null: false
    end
    add_foreign_key :programming_exam_tasks, :programming_exams
    add_foreign_key :programming_exam_tasks, :programming_tasks
  end
end
