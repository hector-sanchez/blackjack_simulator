# frozen_string_literal: true

class GameSession < ApplicationRecord
  enum :status, {
    active: "active",
    completed: "completed"
  }

  validates :game_type, presence: true
  validates :state, presence: true
  validates :status, presence: true
end
