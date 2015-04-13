require 'rails_helper'

require Rails.root.join('db', 'seeds', 'seed_event')
Dir[Rails.root.join("app/mailers/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/mailers/previews/**/*.rb")].each { |f| require f }

RSpec.describe 'mailer previews' do
  DEVISE_METHODS = [:scope_name, :resource, :unlock_instructions]

  def find_preview_class(mailer_class)
    if mailer_class == Devise::Mailer
      Devise::MailerPreview
    else
      mailer_name = mailer_class.to_s.sub('Mailer', '')
      "#{mailer_name}Preview".constantize
    end
  end

  def find_leaves(klass)
    subclasses = klass.subclasses
    return klass if subclasses.empty?

    subclasses.map { |klass| find_leaves(klass) }.flatten
  end

  before do
    Seeder::seed_event(students_per_level_range: (1..1))

    @mailer_classes = find_leaves(ActionMailer::Base)

    # Sanity check that these subclass shenanigans are still working
    expect(@mailer_classes.length).to be > 2
  end

  it 'has a preview for every mailer' do
    missing_previews = @mailer_classes.reject do |mailer_class|
      preview_class = find_preview_class(mailer_class)

      mailer_class.instance_methods(false).each do |mailer_method|
        next if DEVISE_METHODS.include?(mailer_method)
        expect(mailer_class).to receive(mailer_method)
      end

      preview_class.instance_methods(false).each do |preview_method|
        preview_class.new.send(preview_method)
      end
    end
    expect(missing_previews).to match_array([])
  end
end