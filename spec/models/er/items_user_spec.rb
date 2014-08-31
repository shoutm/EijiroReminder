require 'spec_helper'

describe Er::ItemsUser do
  it 'has user, item and wordbook_url' do
    expect(build(:er_items_user)).to be_valid
  end

  it 'is not saved without user' do
    expect{create(:er_items_user, user: nil)}.to raise_error \
      ActiveRecord::StatementInvalid
  end

  it 'is not saved without item' do
    expect{create(:er_items_user, item: nil)}.to raise_error \
      ActiveRecord::StatementInvalid
  end

  it 'is not saved without wordbook_url' do
    item_user = build(:er_items_user, wordbook_url: nil)
    expect(item_user.valid?).to be_falsey
    expect(item_user.errors[:wordbook_url].size).to eq(1)
  end
end
