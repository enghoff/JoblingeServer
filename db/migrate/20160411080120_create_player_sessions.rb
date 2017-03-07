class CreatePlayerSessions < ActiveRecord::Migration
  def change
    create_table :player_sessions, id: :uuid do |t|
      t.uuid :user_id
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :duration_in_seconds
      t.timestamps
    end
    add_index :player_sessions, :user_id
    add_foreign_key :player_sessions, :users, on_delete: :cascade
  end
end
