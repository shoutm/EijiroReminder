# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :er_tag, :class => 'Er::Tag' do
    name "name"
    tag 'tag name'
    interval '1' # days
  end
end
