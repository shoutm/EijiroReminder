class Er::ItemsUsersTag < ActiveRecord::Base
  belongs_to :items_user
  belongs_to :tag
end
