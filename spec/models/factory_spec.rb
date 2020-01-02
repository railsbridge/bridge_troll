# frozen_string_literal: true

require 'rails_helper'

describe 'FactoryBot factories' do
  FactoryBot.factories.map(&:name).uniq.each do |factory_name|
    next if factory_name.to_s.starts_with?('event')

    it "has a valid #{factory_name} factory" do
      expect(create(factory_name)).to be_persisted
    end
  end
end
