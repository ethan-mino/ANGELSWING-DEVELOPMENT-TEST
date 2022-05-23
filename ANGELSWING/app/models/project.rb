class Project < ApplicationRecord
	self.inheritance_column = :_type_disabled
	
	# Tells rails to use this uploader for this model
	mount_uploader :thumbnail, ThumbnailUploader
  	belongs_to :user
	has_many :content, dependent: :destroy
	
	TYPE = "project"
	enum type: [:in_house, :external, :international]# Project Type
end