require 'action_mailer'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  user_name:            'eijiro.reminder',
  password:             'tyoieytksxiahhkc',
  authentication:       'plain',
  enable_starttls_auto: true  }
I18n.enforce_available_locales = false
ActionMailer::Base.view_paths= File.dirname(__FILE__) + '/..'
ActionMailer::Base.delivery_method = :test

module Er
  class ReminderMailer < ActionMailer::Base
    def reminder(config, target_user, u_item_array)
      @user = target_user
      @from = config['mail_settings']['from']
      subject = config['mail_settings']['subject']

      # Items should be displayed based on each URL like below because
      # each item may have the same url. Users are supposed to open
      # each url once and test multiple words.
      # ----------
      # url1
      #   item1
      #   item2
      # url2
      #   item3
      #   item4
      # ----------
      # So u_item_array is converted into @urls_items to make
      # it easy for template to display them.
      @urls_w_items = {}
      u_item_array.each do |u_item|
        if not @urls_w_items[u_item.wordbook_url]
          @urls_w_items[u_item.wordbook_url] = []
        end
        @urls_w_items[u_item.wordbook_url].push u_item.item
      end

      mail(to: target_user.email, from: @from, subject: subject) do |format|
        format.text
      end
    end
  end
end
