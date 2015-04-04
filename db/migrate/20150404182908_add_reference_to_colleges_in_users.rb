class AddReferenceToCollegesInUsers < ActiveRecord::Migration
  def change
  	add_reference :users, :college, index: true
  	add_foreign_key :users, :colleges
  end
end
