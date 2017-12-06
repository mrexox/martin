class Message < ActiveRecord::Base
    # Last messages first
    scope :sorted, -> { order('created_at DESC') }
end
