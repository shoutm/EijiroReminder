FactoryGirl.define do
  factory :'tag-none', :class => 'Er::Tag' do
    name      "tag-none"
    tag       'none'
    interval  '1' # days
  end

  factory :'tag-1st', :class => 'Er::Tag' do
    name      "tag-1st"
    tag       '1st'
    interval  '2' # days
  end

  factory :'tag-2nd', :class => 'Er::Tag' do
    name      "tag-2nd"
    tag       '2nd'
    interval  '4' # days
  end

  factory :'tag-3rd', :class => 'Er::Tag' do
    name      "tag-3rd"
    tag       '3rd'
    interval  '8' # days
  end
end
