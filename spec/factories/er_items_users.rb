# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :er_items_user, :class => 'Er::ItemsUser' do
    user nil
    item nil
  end
end
