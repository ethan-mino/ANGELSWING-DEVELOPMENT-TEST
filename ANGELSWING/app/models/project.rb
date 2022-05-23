class Project < ApplicationRecord
	# Tells rails to use this uploader for this model
	mount_uploader :thumbnail, ThumbnailUploader
  	belongs_to :user
	
	self.inheritance_column = :_type_disabled
	
	TYPE = "project"
	enum type: [:in_house, :external, :international]# Project Type
end