require 'rails_helper'

describe "organization index" do
  let(:event) { create(:event, title: 'Some Event') }

  it "shows a map of events with their last event", js: true do
    visit organizations_path

    expect(page).to have_css('#gmaps4rails_map')
  end
end