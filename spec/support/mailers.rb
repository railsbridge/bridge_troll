
RSpec::Matchers.define :be_an_absolute_url do
  match do |actual|
    URI.parse(actual).host.present?
  end
end

shared_examples_for 'a mailer view' do
  def extract_body(mail)
    if mail.multipart?
      mail.parts.find do |p|
        p.content_type.starts_with?('text/html')
      end.body.encoded
    else
      mail.body.encoded
    end
  end

  it "uses absolute URLs" do
    body = extract_body(mail)

    urls = Capybara.string(body).all('a').map { |a| a[:href] }

    urls.each do |url|
      expect(url).to be_an_absolute_url
    end
  end
end
