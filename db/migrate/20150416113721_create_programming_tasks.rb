class CreateProgrammingTasks < ActiveRecord::Migration
  def change
    create_table :programming_tasks do |t|
    	t.text :task
    	t.text :sample_input
    	t.text :sample_output
    	t.string :hint
      t.timestamps null: false
    end
  end
end
