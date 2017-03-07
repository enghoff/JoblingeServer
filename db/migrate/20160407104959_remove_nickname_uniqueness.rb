class RemoveNicknameUniqueness < ActiveRecord::Migration
  def change
    remove_index :users, :nickname
    add_index :users, :nickname
  end
end
