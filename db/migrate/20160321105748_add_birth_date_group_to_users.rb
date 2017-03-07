class AddBirthDateGroupToUsers < ActiveRecord::Migration
  def change
    add_column :users, :birth_date, :date
    add_column :users, :group, :string
  end
end
