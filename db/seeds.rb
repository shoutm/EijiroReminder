# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl'
Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f }

# Initial values for er_tags table.
Er::Tag.delete_all
FactoryGirl.create(:'1day_tag')
FactoryGirl.create(:'3days_tag')
FactoryGirl.create(:'1week_tag')
FactoryGirl.create(:'2weeks_tag')
FactoryGirl.create(:'1month_tag')
FactoryGirl.create(:'2months_tag')
FactoryGirl.create(:'4months_tag')
FactoryGirl.create(:'done_tag')
