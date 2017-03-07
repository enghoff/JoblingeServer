class AddTimeStampsToGroupsAndLocations < ActiveRecord::Migration
  def change
    add_timestamps :groups
    add_timestamps :locations
  end
end
