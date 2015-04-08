class AddReferenceToQuestioncategoryInQuestion < ActiveRecord::Migration
  def change
  	add_reference :questions, :question_category, index: true
  	add_foreign_key :questions, :question_categories
  end
end
