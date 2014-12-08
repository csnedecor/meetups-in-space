class MeetupsUser < ActiveRecord::Base
  belongs_to :meetup
  belongs_to :user
end
