class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
    	t.references :programming_task, index: true
    	t.string :input_file_name
    	t.string :output_file_name
    	t.integer :marks
      t.timestamps null: false
    end
    add_foreign_key :test_cases, :programming_tasks
  end
end
