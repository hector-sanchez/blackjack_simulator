# frozen_string_literal: true

module Games
  module Blackjack
    class GameSerializer
      def initialize(game)
        @game = game
      end

      def to_snapshot_h
        {
          state: @game.state.to_s,
          outcome: @game.outcome&.to_s,
          player_cards: card_hashes(@game.player_hand.cards),
          dealer_cards: card_hashes(@game.dealer_hand.cards),
          remaining_cards: card_hashes(@game.remaining_cards)
        }
      end

      def to_public_h
        {
          state: @game.state.to_s,
          outcome: @game.outcome&.to_s,
          player_cards: card_hashes(@game.player_hand.cards),
          dealer_cards: card_hashes(@game.visible_dealer_cards),
          legal_actions: @game.legal_actions.map(&:to_s)
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

      private

      def card_hashes(cards)
        cards.map { |card| { suit: card.suit, rank: card.rank } }
      end
    end
  end
end
