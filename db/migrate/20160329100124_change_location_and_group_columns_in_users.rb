class ChangeLocationAndGroupColumnsInUsers < ActiveRecord::Migration

  def up
    remove_column :users, :group
    remove_column :users, :location
  end

  def down
    add_column :users, :group, :string
    add_column :users, :location, :string
  end

  def change
    add_reference :users, :group,    type: :uuid
    add_reference :users, :location, type: :uuid
    add_foreign_key :users, :groups
    add_foreign_key :users, :locations
  end
end
