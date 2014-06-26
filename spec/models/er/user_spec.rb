require 'spec_helper'

describe Er::User do
  it 'has name, email and password' do
    expect(build(:sample_user)).to be_valid
  end

  it 'is invalid without name' do
    expect(build(:sample_user, name: nil)).to have(1).errors_on(:name)
  end

  it 'is invalid without email' do
    expect(build(:sample_user, email: nil)).to have(1).errors_on(:email)
  end

  it 'is invalid without password' do
    expect(build(:sample_user, password: nil)).to have(1).errors_on(:password)
  end
end
