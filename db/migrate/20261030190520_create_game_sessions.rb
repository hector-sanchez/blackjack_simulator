class CreateGameSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :game_sessions do |t|
      t.string :game_type, null: false
      t.jsonb :state, null: false, default: {}
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :game_sessions, :status
  end
end
