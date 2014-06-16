# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :er_items_users_tag, :class => 'Er::ItemsUsersTag' do
    items_user nil
    tag nil
  end
end
