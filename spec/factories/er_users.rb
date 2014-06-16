# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :er_user, :class => 'Er::User' do
    name "MyString"
    email "MyString"
    password "MyString"
  end
end
