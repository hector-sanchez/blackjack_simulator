# frozen_string_literal: true

module Games
  module Blackjack
    class Deck
      class EmptyError < StandardError; end

      def initialize(cards: nil)
        @cards =
          if cards
            cards.dup
          else
            Games::Blackjack::Card::SUITS.product(Games::Blackjack::Card::RANKS).map do |suit, rank|
              Games::Blackjack::Card.new(suit: suit, rank: rank)
            end
          end
      end

      def cards
        @cards.dup
      end

      def shuffle!
        @cards.shuffle!
        self
      end

      def draw
        raise EmptyError if empty?

        @cards.shift
      end

      def remaining
        @cards.size
      end

      def empty?
        @cards.empty?
      end
    end
  end
end
