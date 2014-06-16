require 'spec_helper'

describe Er::Item do
  it 'has e_id, name' do
    expect(build(:er_item)).to be_valid
  end

  it 'is invalid without e_id' do
    expect(build(:er_item, e_id: nil)).to have(1).errors_on(:e_id)
  end

  it 'is invalid without name' do
    expect(build(:er_item, name: nil)).to have(1).errors_on(:name)
  end
end
