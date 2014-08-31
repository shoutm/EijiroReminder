require 'spec_helper'

describe Er::Item do
  it 'has e_id, name' do
    expect(build(:er_item)).to be_valid
  end

  it 'is invalid without e_id' do
    item = build(:er_item, e_id: nil)
    expect(item.valid?).to be_falsey
    expect(item.errors[:e_id].size).to eq(1)
  end

  it 'is invalid without name' do
    item = build(:er_item, name: nil)
    expect(item.valid?).to be_falsey
    expect(item.errors[:name].size).to eq(1)
  end
end
