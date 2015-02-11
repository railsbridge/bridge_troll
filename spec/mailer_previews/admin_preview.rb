class AdminPreview < ActionMailer::Preview
  def test_group_mail
    options = { :to => 'test@example.com' }
    AdminMailer.test_group_mail(options)
  end

  def test_individual_mail
    options = { :to => 'test@example.com' }
    AdminMailer.test_individual_mail(options)
  end

end
