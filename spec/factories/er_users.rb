require 'faker'

FactoryGirl.define do
  factory :er_user, :class => 'Er::User' do
    name      { Faker::Name.name }
    email     { Faker::Internet.email }
    password  { Faker::Internet.password }
  end
end
