class AddEndTimeColumnInAnswerSheet < ActiveRecord::Migration
  def change
  	add_column :answer_sheets, :end_time, :datetime
  end
end
