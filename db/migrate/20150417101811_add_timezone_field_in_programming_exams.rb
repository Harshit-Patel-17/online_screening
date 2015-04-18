class AddTimezoneFieldInProgrammingExams < ActiveRecord::Migration
  def change
  	add_column :programming_exams, :timezone, :string
  end
end
