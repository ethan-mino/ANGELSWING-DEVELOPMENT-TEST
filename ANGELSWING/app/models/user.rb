class User < ApplicationRecord
	has_secure_password
	has_many :project
	
	TYPE = "users"
	
	def User.username(first_name, last_name)
		last_name + " " + first_name
	end
end
