class CreateGameData < ActiveRecord::Migration
  def change
    create_table :game_data, id: :uuid do |t|
      t.json :data, default: {}
      t.uuid :user_id
      t.timestamps
    end
    add_index :game_data, :user_id
    add_foreign_key :game_data, :users, on_delete: :cascade
  end
end
