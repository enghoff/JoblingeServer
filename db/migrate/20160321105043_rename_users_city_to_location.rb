class RenameUsersCityToLocation < ActiveRecord::Migration
  def change
    rename_column :users, :city, :location
  end
end
