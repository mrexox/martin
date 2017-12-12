class Slide < ActiveRecord::Base
	mount_uploader :photo, SlidePhotoUploader
	serialize :photo, JSON
end
