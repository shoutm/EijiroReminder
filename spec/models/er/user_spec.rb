require 'spec_helper'

describe Er::User do
  it 'has name, email and password' do
    expect(build(:sample_user)).to be_valid
  end

  it 'is invalid without name' do
    sample_user = build(:sample_user, name: nil)
    expect(sample_user.valid?).to be_falsey
    expect(sample_user.errors[:name].size).to eq(1)
  end

  it 'is invalid without email' do
    sample_user = build(:sample_user, email: nil)
    expect(sample_user.valid?).to be_falsey
    expect(sample_user.errors[:email].size).to eq(1)
  end

  it 'is invalid without password' do
    sample_user = build(:sample_user, password: nil)
    expect(sample_user.valid?).to be_falsey
    expect(sample_user.errors[:password].size).to eq(1)
  end
end
