# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :er_items_users_tag, :class => 'Er::ItemsUsersTag' do
    association :items_user, factory: :er_items_user
    association :tag, factory: :'1day_tag'
  end

  factory :default_items_users_tag, :class => 'Er::ItemsUsersTag' do
    association :items_user, factory: :default_items_user
    association :tag, factory: :'1day_tag'
  end
end
