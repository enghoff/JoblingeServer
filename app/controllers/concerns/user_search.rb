class UserSearch < Search

  private

  def base_query
    User
      .joins(:group, :location)
      .select("users.*, groups.name AS group_name, locations.name AS location_name")
  end

  def virtual_columns
    {
      "group_name"     => "groups.name",
      "location_name"  => "locations.name",
    }
  end

end
