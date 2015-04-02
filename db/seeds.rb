# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if User.all.length == 0
	puts 'Seeding user...'
	User.create!(email: 'admin@infibeam.net', first_name: 'admin', password: 'infibeam')
end

if Role.all.length == 0
	puts 'Seeding roles...'
	Role.create!(role_name: 'admin')
	Role.create!(role_name: 'user')
end

if Privilege.all.length == 0
	puts 'Seeding privilege...'
	user_id = User.find_by_email('admin@infibeam.net')[:id]
	role_id = Role.find_by_role_name('admin')[:id]
	Privilege.create!(user_id: user_id, role_id: role_id)
end