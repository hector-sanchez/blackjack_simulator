# frozen_string_literal: true

module Games
  module Blackjack
    class Card
      RANKS = ((2..10).to_a + %w[J Q K A]).freeze
      SUITS = %w[hearts diamonds clubs spades].freeze

      attr_reader :suit, :rank

      def initialize(suit:, rank:)
        raise ArgumentError, "Invalid suit" unless SUITS.include?(suit)
        raise ArgumentError, "Invalid rank" unless RANKS.include?(rank)

        @suit = suit.dup.freeze
        @rank = rank.is_a?(String) ? rank.dup.freeze : rank
      end

      def ==(other)
        other.is_a?(Card) && suit == other.suit && rank == other.rank
      end
      alias eql? ==

      def hash
        [ self.class, suit, rank ].hash
      end
    end
  end
end
