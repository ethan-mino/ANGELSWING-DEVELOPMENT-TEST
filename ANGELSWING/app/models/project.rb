class Project < ApplicationRecord
	# Tells rails to use this uploader for this model
	mount_uploader :thumbnail, ThumbnailUploader
	
	self.inheritance_column = :_type_disabled
  	belongs_to :user
end
