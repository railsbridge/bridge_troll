desc "Send reminders for upcoming events within the reminder window"
task send_reminders: :environment do
  puts "Sending reminder emails..."
  ReminderSender.send_all_reminders
  puts "...done."
end

desc "Send surveys for all past events"
task send_surveys: :environment do
  puts "Sending surveys..."
  SurveySender.send_all_surveys
  puts "...done."
end
