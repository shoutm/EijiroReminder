# encoding: UTF-8

module Er
  class Reminder
    def run
    end

    def pick_items_from_db(user_id)
      picked_items = []
      items_user_ary = Er::ItemsUser.where(user_id: user_id)
      items_user_ary.each do |items_user|
        tags = Er::ItemsUsersTag.where(items_user: items_user.id)
        if tags == []
          picked_items.push items_user.item_id
        end
      end

      return picked_items
    end

    def send_items_by_email(user_id, item_id_array)
    end
  end
end
