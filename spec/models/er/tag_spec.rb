require 'spec_helper'

describe Er::Tag do
  it 'has name, tag, interval and order' do
    expect(build(:'test_tag1')).to be_valid
  end

  it 'is invalid without name' do
    expect(build(:'1day_tag', name: nil)).to have(1).errors_on(:name)
  end

  it 'is invalid without tag' do
    expect(build(:'1day_tag', tag: nil)).to have(1).errors_on(:tag)
  end

  it 'is invalid without interval' do
    expect(build(:'1day_tag', interval: nil)).to have(1).errors_on(:interval)
  end

  it 'is invalid without order' do
    expect(build(:'1day_tag', order: nil)).to have(1).errors_on(:order)
  end

  it 'is invalid when there is an existing entry with the same order' do
    create(:'test_tag1')
    expect(build(:'test_tag1')).to have(1).errors_on(:order)
  end
end
