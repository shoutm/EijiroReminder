require 'spec_helper'

describe Er::ItemsUsersTag do
  it 'has items_user, tag and registration_date' do
    expect(build(:er_items_user)).to be_valid
  end

  it 'is not saved without items_user' do
    expect{create(:er_items_users_tag, items_user: nil)}.to raise_error \
      ActiveRecord::StatementInvalid
  end

  it 'is not saved without tag' do
    expect{create(:er_items_users_tag, tag: nil)}.to raise_error \
      ActiveRecord::StatementInvalid
  end

  it 'is not saved without registation_date' do
    expect(build(:er_items_users_tag, registration_date: nil)).to have(1).errors_on(:registration_date)
  end
end
