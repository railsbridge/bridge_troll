# frozen_string_literal: true

require 'rails_helper'

describe 'visiting the style guide' do
  describe 'as an unauthenticated user' do
    it 'can view page' do
      visit '/style_guide'

      expect(page).to have_content('Style Guide')
    end

    it "can redirect from '/styleguide' to #style_guide" do
      visit '/styleguide'

      expect(page).to have_current_path '/style_guide'
    end
  end
end
