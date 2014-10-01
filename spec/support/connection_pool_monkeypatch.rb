# Monkey-patch to force single DB connection even in multithreaded
#   tests (selenium/capybara-webkit/poltergeist)
ActiveRecord::ConnectionAdapters::ConnectionPool.class_eval do
  def current_connection_id
    Thread.main.object_id
  end
end