require 'faker'

FactoryGirl.define do
  factory :er_item, :class => 'Er::Item' do
    e_id { Faker::Number.digit }
    name "Sample word"
  end
end
