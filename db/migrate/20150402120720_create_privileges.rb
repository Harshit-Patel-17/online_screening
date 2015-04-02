class CreatePrivileges < ActiveRecord::Migration
  def change
    create_table :privileges do |t|
    	t.references :user, index: true
    	t.references :role, index: true
      t.timestamps null: false
    end
    add_foreign_key :privileges, :users
    add_foreign_key :privileges, :roles
  end
end
