class Er::ItemsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  has_many   :tags, :foreign_key => 'items_user_id',
                    :class_name => 'Er::ItemsUsersTag'
  validates  :wordbook_url, presence: true
end
