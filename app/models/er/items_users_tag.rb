class Er::ItemsUsersTag < ActiveRecord::Base
  belongs_to :items_user
  belongs_to :tag
  validates  :registration_date, presence: true
end
