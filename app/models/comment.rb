class Comment < ActiveRecord::Base
  belongs_to :meetup
  belongs_to :user

  validates_presence_of :body
end
