# frozen_string_literal: true

require 'rails_helper'

describe StaticPagesController do
  describe 'GET #style_guide' do
    before do
      get :style_guide
    end

    it 'resonds with a success message' do
      expect(response.status).to eq(200)
    end

    it "renders the 'style_guide' template" do
      expect(response).to render_template(:style_guide)
    end
  end

  describe 'GET #about' do
    before do
      get :about
    end

    it 'resonds with a success message' do
      expect(response.status).to eq(200)
    end

    it "renders the 'about' template" do
      expect(response).to render_template(:about)
    end
  end
end
