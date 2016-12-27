class AccountMerger
  def initialize(user_to_keep, user_to_merge)
    @user_to_keep = user_to_keep
    @user_to_merge = user_to_merge
  end

  def merge!
    raise "Can't merge the same user onto itself!" if @user_to_merge.id == @user_to_keep.id

    to_destroy = Rsvp.where(event_id: (
        @user_to_merge.rsvps.pluck('event_id') & @user_to_keep.rsvps.pluck('event_id')
       ), user_id: @user_to_merge.id, user_type: 'User')

    Rails.logger.info(<<-EOT.strip_heredoc)

      Ready to merge #{user_desc(@user_to_merge)}'s data onto #{user_desc(@user_to_keep)}!

      #{to_destroy.count} RSVP(s) of #{user_desc(@user_to_merge)} will be DESTROYED
      #{@user_to_merge.rsvps.count - to_destroy.count} RSVP(s) will be adopted by #{user_desc(@user_to_keep)}

      Is this cool? (y/n)
    EOT

    return unless get_answer.casecmp('y')

    to_destroy.destroy_all

    @user_to_merge.rsvps.update_all(user_id: @user_to_keep.id)
    @user_to_merge.destroy

    true
  end

  private

  def get_answer
    gets.chomp
  end

  def user_desc(user)
    "#{user.full_name} (#{user.id})"
  end
end