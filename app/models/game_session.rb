# frozen_string_literal: true

class GameSession < ApplicationRecord
  enum :status, {
    active: "active",
    completed: "completed"
  }

  validates :state, presence: true
  validates :status, presence: true
end
