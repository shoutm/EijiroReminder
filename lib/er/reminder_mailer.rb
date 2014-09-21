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
    def reminder(config, target_user, item_array)
      @user = target_user
      @items = item_array
      from = config['mail_settings']['from']
      subject = config['mail_settings']['subject']
      mail(to: target_user.email,
           from: from,
           subject: subject
          ) do |format|
        format.text
      end
    end
  end
end
