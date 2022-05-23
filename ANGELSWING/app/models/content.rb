class Content < ApplicationRecord
	belongs_to :user
	belongs_to :project
	
	TYPE = "content"
end
