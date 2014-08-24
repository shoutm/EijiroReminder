# encoding: UTF-8

module Er
  class Reminder
    def run
    end

    def pick_items_from_db(user_id)
      picked_items = []
      items_user_ary = Er::ItemsUser.where(user_id: user_id)
      items_user_ary.each do |items_user|
        tags_info = Er::ItemsUsersTag.where(items_user: items_user.id)

        # Get a tag which has the biggest order value
        last_tag_info = tags_info.sort do |a,b|
          a.tag.order <=> b.tag.order
        end.last

        if last_tag_info == nil or
           (last_tag_info.tag.interval != Er::Tag.INTERVAL_NEVER and
            Time.now >= last_tag_info.registration_date + \
              last_tag_info.tag.interval)
          picked_items.push items_user.item
        end
      end

      return picked_items
    end

    def send_items_by_email(user_id, item_id_array)
    end
  end
end
