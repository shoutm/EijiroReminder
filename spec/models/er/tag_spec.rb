require 'spec_helper'

describe Er::Tag do
  it 'has name, tag and interval' do
    expect(build(:er_tag)).to be_valid
  end
end
