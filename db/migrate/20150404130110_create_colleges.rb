class CreateColleges < ActiveRecord::Migration
  def change
    create_table :colleges do |t|
    	t.string :institute_name
    	t.string :branch_name
      t.timestamps null: false
    end
  end
end
