class CreateMeetupsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :meetups_users do |t|
      t.integer :user_id, null: false
      t.integer :meetup_id, null: false
    end
  end
end
