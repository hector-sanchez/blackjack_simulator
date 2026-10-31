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

      def self.hit!(session)
        perform_action!(session, :hit)
      end

      def self.stand!(session)
        perform_action!(session, :stand)
      end

      def self.perform_action!(session, action)
        session.with_lock do
          game = load(session)

          case action
          when :hit
            game.hit!
          when :stand
            game.stand!
          end

          session.update!(
            state: GameSerializer.new(game).to_h,
            status: game.finished? ? "completed" : "active"
          )

          game
        end
      end

      private_class_method :perform_action!
    end
  end
end
