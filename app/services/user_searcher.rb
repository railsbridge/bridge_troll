class UserSearcher
  def initialize(relation, query)
    @relation = relation
    @query = query
  end

  def as_json(options = {})
    search_field = @relation.connection.concat('lower(first_name)', "' '", 'lower(last_name)')
    @relation
      .select(:id, :first_name, :last_name)
      .where("#{search_field} like ?", "%#{@query.downcase}%")
      .map { |u| {id: u.id, text: u.full_name} }
  end

  private

  def db_concat(*fields)
    if false
      "CONCAT(#{fields.join(', ')})"
    else
      fields.join(' || ')
    end
  end
end