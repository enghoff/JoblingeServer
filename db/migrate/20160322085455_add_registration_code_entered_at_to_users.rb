class AddRegistrationCodeEnteredAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registration_code_entered_at, :datetime
  end
end
