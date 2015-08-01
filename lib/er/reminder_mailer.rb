require 'action_mailer'

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
      # So u_item_array is converted into @urls_w_items to make
      # it easy for template to display them.
      @urls_w_items = {}
      u_item_array.each do |u_item|
        if not @urls_w_items[u_item.wordbook_url]
          @urls_w_items[u_item.wordbook_url] = []
        end
        @urls_w_items[u_item.wordbook_url].push u_item.item
      end

      # Sort by page number
      @sorted_urls = @urls_w_items.keys.sort do |url1, url2|
        url1.match /page=(\d+)/
        url1_page = $1
        url2.match /page=(\d+)/
        url2_page = $1
        url1_page.to_i <=> url2_page.to_i
      end

      mail(to: target_user.email, from: @from, subject: subject) do |format|
        format.text
      end
    end
  end
end
