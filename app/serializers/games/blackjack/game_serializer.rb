# frozen_string_literal: true

module Games
  module Blackjack
    class GameSerializer
      def initialize(game)
        @game = game
      end

      def to_h
        {
          state: @game.state.to_s,
          outcome: @game.outcome&.to_s,
          player_cards: @game.player_hand.cards.map { |card| { suit: card.suit, rank: card.rank } },
          dealer_cards: @game.dealer_hand.cards.map { |card| { suit: card.suit, rank: card.rank } },
          remaining_cards: @game.remaining_cards.map { |card| { suit: card.suit, rank: card.rank } }
        }
      end

      def self.load(data)
        data = data.deep_stringify_keys

        build_cards = lambda do |cards|
          cards.map do |card|
            Card.new(
              suit: card.fetch("suit"),
              rank: card.fetch("rank")
            )
          end
        end

        Game.restore(
          deck: Deck.new(cards: build_cards.call(data.fetch("remaining_cards"))),
          player_hand: Hand.new(build_cards.call(data.fetch("player_cards"))),
          dealer_hand: Hand.new(build_cards.call(data.fetch("dealer_cards"))),
          state: data.fetch("state").to_sym,
          outcome: data["outcome"]&.to_sym
        )
      end
    end
  end
end
