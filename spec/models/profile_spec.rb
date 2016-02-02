require 'rails_helper'

describe Profile do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:user) }

  describe "uniqueness" do
    let!(:profile) { create(:user).profile }

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
end

