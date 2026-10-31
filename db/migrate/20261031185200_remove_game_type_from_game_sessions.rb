# frozen_string_literal: true

class RemoveGameTypeFromGameSessions < ActiveRecord::Migration[8.1]
  def change
    remove_column :game_sessions, :game_type, :string
  end
end
