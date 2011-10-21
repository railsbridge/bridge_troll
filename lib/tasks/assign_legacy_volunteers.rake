desc "Old volunteers weren't assigned to specific workshops. This guesses where they volunteered."
task :assign_legacy_volunteers => :environment do
  User.all.each do |user|
    may = Event.find_by_name('May 2011 Ruby on Rails Outreach Workshop for Women')
    aug = Event.find_by_name('August 2011 Ruby on Rails Outreach Workshop for Women')
    if user.created_at < Date.parse("May 10, 2011")
      may.volunteers << user
    elsif user.created_at < Date.parse("August 15, 2011")
      aug.volunteers << user
    end
  end
end