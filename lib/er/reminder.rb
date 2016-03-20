# encoding: UTF-8

module Er
  class Reminder
    class << self
      attr_reader :MAX_PICKUP_ITEMS_NUM
    end

    @MAX_PICKUP_ITEMS_NUM = 10

    def initialize(config_path: \
                   Rails.root.join('lib/config/er_reminder_config.yaml'))
      @config = YAML.load_file config_path
      _initialize_mail_settings(@config['smtp_settings'])
    end

    def run
      all_users = _pick_all_users_from_db
      all_users.each do |user|
        send_items_by_email user
      end
    end

    def send_items_by_email(user)
      u_item_array = _pick_items_from_db(user)
      if u_item_array.size != 0
        Er::ReminderMailer.reminder(@config, user, u_item_array).deliver
      end
    end

    private

    def _initialize_mail_settings(smtp_settings)
      ActionMailer::Base.delivery_method = Rails.env == 'test' ? :test : :smtp
      ActionMailer::Base.view_paths= File.dirname(__FILE__) + '/..'
      ActionMailer::Base.raise_delivery_errors = true
      ActionMailer::Base.smtp_settings = {
        address:              smtp_settings['address'],
        port:                 smtp_settings['port'],
        user_name:            smtp_settings['user_name'],
        password:             smtp_settings['password'],
        authentication:       smtp_settings['authentication'],
        enable_starttls_auto: smtp_settings['enable_starttls_auto']  }
    end

    def _pick_all_users_from_db
      return Er::User.all
    end

    def _pick_items_from_db(user_id)
      picked_items = []
      items_user_ary = Er::ItemsUser.joins(:item).where(
        er_items: {disabled: false}, user_id: user_id)
      items_user_ary.each do |items_user|
        tags_info = Er::ItemsUsersTag.where(items_user: items_user.id)

        # Get a tag which has the biggest order value
        last_tag_info = tags_info.sort do |a,b|
          a.tag.order <=> b.tag.order
        end.last

        if last_tag_info == nil or
           (last_tag_info.tag.interval != Er::Tag.INTERVAL_NEVER and
            Time.now >= last_tag_info.registration_date + \
              last_tag_info.tag.interval.days)
          picked_items.push items_user
        end
      end

      return picked_items[0..(Er::Reminder.MAX_PICKUP_ITEMS_NUM - 1)]
    end
  end
end
