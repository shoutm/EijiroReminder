# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :er_items_users_tag, :class => 'Er::ItemsUsersTag' do
    association :items_user, factory: :er_items_user
    association :tag, factory: :'test_tag1'
  end

  factory :default_items_users_tag, :class => 'Er::ItemsUsersTag' do
    association :items_user, factory: :default_items_user
    association :tag, factory: :'test_tag2'
  end
end
