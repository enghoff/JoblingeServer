class AddBasicColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nickname, :string
    add_column :users, :gender, :integer, default: 0
    add_column :users, :city, :string
  end
end
