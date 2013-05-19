desc "This task is called by the Heroku scheduler add-on"
task :send_reminders => :environment do
  puts "Sending reminder emails..."
  ReminderSender.send_all_reminders
  puts "...done."
end
