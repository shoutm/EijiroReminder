FactoryGirl.define do
  # -----------------------------------------
  # These are for production initial values
  # -----------------------------------------
  factory :'1day_tag', :class => 'Er::Tag' do
    name      "1Day"
    tag       '1:1day'
    interval  '3' # days
    order     '1'
  end

  factory :'3days_tag', :class => 'Er::Tag' do
    name      "3Days"
    tag       '2:3days'
    interval  '7' # days
    order     '2'
  end

  factory :'1week_tag', :class => 'Er::Tag' do
    name      "1Week"
    tag       '3:1week'
    interval  '14' # days
    order     '3'
  end

  factory :'2weeks_tag', :class => 'Er::Tag' do
    name      "2Weeks"
    tag       '4:2weeks'
    interval  '31' # days
    order     '4'
  end

  factory :'1month_tag', :class => 'Er::Tag' do
    name      "1Month"
    tag       '5:1month'
    interval  '62' # days
    order     '5'
  end

  factory :'2months_tag', :class => 'Er::Tag' do
    name      "2Months"
    tag       '6:2months'
    interval  '124' # days
    order     '6'
  end

  factory :'4months_tag', :class => 'Er::Tag' do
    name      "4Months"
    tag       '7:4months'
    interval  '248' # days
    order     '7'
  end

  factory :'done_tag', :class => 'Er::Tag' do
    name      "Done"
    tag       '8:done'
    interval  '-1' # days
    order     '8'
  end

  # -----------------------------------------
  # Test values from now on
  # -----------------------------------------
  factory :'test_tag1', :class => 'Er::Tag' do
    name      "Test_tag1"
    tag       'test_tag1'
    interval  '1' # days
    order     '10'
  end

  factory :'test_tag2', :class => 'Er::Tag' do
    name      "Test_tag2"
    tag       'test_tag2'
    interval  '2' # days
    order     '11'
  end

  factory :'test_tagdone', :class => 'Er::Tag' do
    name      "Test_tagdone"
    tag       'test_tagdone'
    interval  '-1' # days
    order     '12'
  end
end
