class CreateExamColleges < ActiveRecord::Migration
  def change
    create_table :exam_colleges do |t|
    	t.references :exam, index: true
      t.references :college, index: true
      t.timestamps null: false
    end
    add_foreign_key :exam_colleges, :exams
    add_foreign_key :exam_colleges, :colleges
  end
end
