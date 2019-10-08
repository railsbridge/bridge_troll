module Seeder
  def self.admin_user
    # seeds the database with an admin user
    admin = User.where(email: 'admin@example.com').first_or_initialize
    admin.update(
      password: 'password',
      first_name: 'Admin',
      last_name: 'User',
      time_zone: 'Pacific Time (US & Canada)',
      admin: true
    )
    admin.confirm
    admin.save!
  end
end
