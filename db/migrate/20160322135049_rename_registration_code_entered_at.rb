class RenameRegistrationCodeEnteredAt < ActiveRecord::Migration
  def change
    rename_column :users, :registration_code_entered_at, :registered_at
  end
end
