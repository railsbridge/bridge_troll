# frozen_string_literal: true

require 'rails_helper'

describe Profile do
  it { is_expected.to belong_to(:user).required }

  describe 'uniqueness' do
    # when we don't create a profile, we get a PG foreign key error
    before { create(:user).profile }

    it { is_expected.to validate_uniqueness_of(:user_id) }
  end

  it 'validates the format of github_username' do
    def prof(github_username)
      Profile.new(github_username: github_username)
    end

    expect(prof('-robocop')).to have(1).errors_on(:github_username)
    expect(prof('coborop-')).to have(1).errors_on(:github_username)
    expect(prof('i have spaces')).to have(1).errors_on(:github_username)
    expect(prof('http://github.com/username')).to have(1).errors_on(:github_username)

    expect(prof('foo-BAR-91')).to have(0).errors_on(:github_username)
    expect(prof(nil)).to have(0).errors_on(:github_username)
  end

  it 'validates the format of twitter_username' do
    def prof(twitter_username)
      Profile.new(twitter_username: twitter_username)
    end

    expect(prof('hello world')).to have(1).errors_on(:twitter_username)
    expect(prof('helloworld')).to have(0).errors_on(:twitter_username)
    expect(prof('@helloworld')).to have(0).errors_on(:twitter_username)
  end

  it 'removes leading @ signs from twitter username' do
    profile = described_class.new(twitter_username: '@banana')
    expect(profile.twitter_username).to eq('banana')
  end
end
