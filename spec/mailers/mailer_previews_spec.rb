require 'rails_helper'

require Rails.root.join('db', 'seeds', 'seed_event')
Dir[Rails.root.join("app", "mailers", "*.rb")].each { |f| require f }
Dir[Rails.root.join("spec", "mailers", "previews", "**", "*.rb")].each { |f| require f }

RSpec.describe 'mailer previews' do
  def find_preview_class(mailer_class)
    mailer_name = mailer_class.to_s.sub('Mailer', '')
    "#{mailer_name}Preview".constantize
  end

  def find_leaves(klass)
    subclasses = klass.subclasses
    return klass if subclasses.empty?

    subclasses.map { |klass| find_leaves(klass) }.flatten
  end

  before do
    Seeder.seed_event(students_per_level_range: (1..1))
    Seeder.seed_multiple_location_event
  end

  it 'has a preview for every devise mail' do
    devise_templates = Dir[Rails.root.join('app', 'views', 'devise', 'mailer', '*')]
    expect(devise_templates.length).to be >= 2

    devise_mailer_methods = devise_templates.map { |t| File.basename(t).split('.')[0] }
    devise_mailer_methods.each do |mailer_method|
      expect(Devise::Mailer).to receive(mailer_method)
    end

    Devise::MailerPreview.instance_methods(false).each do |preview_method|
      Devise::MailerPreview.new.send(preview_method)
    end
  end

  describe 'for non-devise mailer classes' do
    before do
      @mailer_classes = find_leaves(ActionMailer::Base) - [Devise::Mailer]

      # Sanity check that these subclass shenanigans are still working
      expect(@mailer_classes.length).to be > 2
    end

    it 'has a preview for every normal mail' do
      missing_previews = @mailer_classes.reject do |mailer_class|
        preview_class = find_preview_class(mailer_class)

        mailer_class.instance_methods(false).each do |mailer_method|
          expect(mailer_class).to receive(mailer_method).at_least(:once).and_call_original
        end

        preview_class.instance_methods(false).each do |preview_method|
          mail = preview_class.new.send(preview_method)
          # render the message to ensure the arity and template content works
          expect(mail.message.subject.length).to be > 1
        end
      end
      expect(missing_previews).to match_array([])
    end
  end
end