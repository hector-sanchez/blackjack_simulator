# frozen_string_literal: true

module Games
  module Blackjack
    class SessionManager
      def self.start!
        game = Game.new
        game.start!

        GameSession.create!(
          game_type: "blackjack",
          state: GameSerializer.new(game).to_h,
          status: game.finished? ? "completed" : "active"
        )
      end

      def self.load(session)
        GameSerializer.load(session.state)
      end
    end
  end
end
