
RSpec::Matchers.define :be_an_absolute_url do
  match do |actual|
    URI.parse(actual).host.present?
  end
end

shared_examples_for 'a mailer view' do
  it "uses absolute URLs" do
    if mail.multipart?
      body = mail.parts.find do |p|
        p.content_type.starts_with?('text/html')
      end.body.encoded
    else 
      body = mail.body.encoded
    end

    urls = Capybara.string(body).all('a').map { |a| a[:href] }

    urls.each do |url|
      expect(url).to be_an_absolute_url
    end
  end
end
