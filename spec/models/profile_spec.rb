require 'rails_helper'

describe Profile do
  it { should belong_to(:user) }
  it { should validate_presence_of(:user) }
  it { should validate_uniqueness_of(:user_id) }

  it 'validates the format of github_username' do
    def prof(github_username)
      Profile.new(github_username: github_username)
    end

    prof('-robocop').should have(1).errors_on(:github_username)
    prof('coborop-').should have(1).errors_on(:github_username)
    prof('i have spaces').should have(1).errors_on(:github_username)
    prof('http://github.com/username').should have(1).errors_on(:github_username)

    prof('foo-BAR-91').should have(0).errors_on(:github_username)
    prof(nil).should have(0).errors_on(:github_username)
  end
end

