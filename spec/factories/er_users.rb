require 'faker'

FactoryGirl.define do
  @config_path = Rails.root.join('spec/config/crawler_config.yaml')
  @config = YAML.load_file @config_path
  id = @config['default_user']['id']
  password = @config['default_user']['password']

  factory :sample_user, :class => 'Er::User' do
    name      { Faker::Name.name }
    email     { Faker::Internet.email }
    password  { Faker::Internet.password }
  end

  factory :default_user, :class => 'Er::User' do
    name      'Default User'
    email     id
    password  password
  end
end
