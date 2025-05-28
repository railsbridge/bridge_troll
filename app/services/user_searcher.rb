# frozen_string_literal: true

class UserSearcher
  def initialize(relation, query)
    @relation = relation
    @query = query
  end

  def as_json(_options = {})
    args = 'lower(first_name)', "' '", 'lower(last_name)'
    search_field = if Rails.application.using_postgres?
                     "CONCAT(#{args * ', '})"
                   else
                     args * ' || '
                   end

    @relation
      .select(:id, :first_name, :last_name)
      .where("#{search_field} like ?", "%#{@query.downcase}%")
      .map { |u| { id: u.id, text: u.full_name } }
  end
end
