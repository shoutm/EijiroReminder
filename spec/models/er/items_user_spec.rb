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
    expect(build(:er_items_user, wordbook_url: nil)).to have(1).errors_on(:wordbook_url)
  end
end
