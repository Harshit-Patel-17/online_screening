class AddTaskNameFieldInProgrammingTask < ActiveRecord::Migration
  def change
  	add_column :programming_tasks, :task_name, :string
  end
end
