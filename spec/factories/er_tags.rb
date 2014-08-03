FactoryGirl.define do
  factory :'1day_tag', :class => 'Er::Tag' do
    name      "1Day"
    tag       '1:1day'
    interval  '3' # days
  end

  factory :'3days_tag', :class => 'Er::Tag' do
    name      "3Days"
    tag       '2:3days'
    interval  '7' # days
  end

  factory :'1week_tag', :class => 'Er::Tag' do
    name      "1Week"
    tag       '3:1week'
    interval  '14' # days
  end

  factory :'2weeks_tag', :class => 'Er::Tag' do
    name      "2Weeks"
    tag       '4:2weeks'
    interval  '31' # days
  end

  factory :'1month_tag', :class => 'Er::Tag' do
    name      "1Month"
    tag       '5:1month'
    interval  '62' # days
  end

  factory :'2months_tag', :class => 'Er::Tag' do
    name      "2Months"
    tag       '6:2months'
    interval  '124' # days
  end

  factory :'4months_tag', :class => 'Er::Tag' do
    name      "4Months"
    tag       '7:4months'
    interval  '248' # days
  end

  factory :'done_tag', :class => 'Er::Tag' do
    name      "Done"
    tag       '8:done'
    interval  '0' # days
  end
end
