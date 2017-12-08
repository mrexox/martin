class Order < ActiveRecord::Base
	mount_uploader :photo, OrderPhotoUploader
	serialize :photo, JSON
end
