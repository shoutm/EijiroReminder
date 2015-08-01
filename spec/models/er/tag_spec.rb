require 'spec_helper'

describe Er::Tag do
  it 'has name, tag, interval and order' do
    expect(build(:'test_tag1')).to be_valid
  end

  it 'is invalid without name' do
    tag = build(:'1day_tag', name: nil)
    expect(tag.valid?).to be_falsey
    expect(tag.errors[:name].size).to eq(1)
  end

  it 'is invalid without tag' do
    tag = build(:'1day_tag', tag: nil)
    expect(tag.valid?).to be_falsey
    expect(tag.errors[:tag].size).to eq(1)
  end

  it 'is invalid without interval' do
    tag = build(:'1day_tag', interval: nil)
    expect(tag.valid?).to be_falsey
    expect(tag.errors[:interval].size).to eq(1)
  end

  it 'is invalid without order' do
    tag = build(:'1day_tag', order: nil)
    expect(tag.valid?).to be_falsey
    expect(tag.errors[:order].size).to eq(1)
  end

  it 'is invalid when there is an existing entry with the same order' do
    create(:'test_tag1')
    tag = Er::Tag.new(attributes_for(:'test_tag1'))
    expect(tag.valid?).to be_falsey
    expect(tag.errors[:order].size).to eq(1)
  end
end
