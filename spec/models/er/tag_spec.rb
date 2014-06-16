require 'spec_helper'

describe Er::Tag do
  it 'has name, tag and interval' do
    expect(build(:er_tag)).to be_valid
  end

  it 'is invalid without name' do
    expect(build(:er_tag, name: nil)).to have(1).errors_on(:name)
  end

  it 'is invalid without tag' do
    expect(build(:er_tag, tag: nil)).to have(1).errors_on(:tag)
  end

  it 'is invalid without interval' do
    expect(build(:er_tag, interval: nil)).to have(1).errors_on(:interval)
  end
end
