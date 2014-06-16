# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :er_item, :class => 'Er::Item' do
    e_id 1
    name "MyString"
  end
end
