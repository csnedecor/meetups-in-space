class Meetup < ActiveRecord::Base
  has_many :meetups_users
  has_many :users, through: :meetups_users
  has_many :comments

  validates_presence_of :name, message: 'is required.'
  validates_presence_of :description, message: 'is required.'
  validates_presence_of :location, message: 'is required.'
end
