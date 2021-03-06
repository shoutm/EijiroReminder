FactoryGirl.define do
  factory :er_items_user, :class => 'Er::ItemsUser' do
    association :user, factory: :sample_user
    association :item, factory: :er_item
    wordbook_url 'http://eowp.alc.co.jp/wordbook/ej'
  end

  factory :default_items_user, :class => 'Er::ItemsUser' do
    association :user, factory: :default_user
    association :item, factory: :er_item
    wordbook_url 'http://eowp.alc.co.jp/wordbook/ej'
  end
end
