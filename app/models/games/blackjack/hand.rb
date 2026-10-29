# frozen_string_literal: true

module Games
  module Blackjack
    class Hand
      def initialize(cards = [])
        @cards = []
        cards.each { |card| add_card(card) }
      end

      def add_card(card)
        raise ArgumentError, "Invalid card" unless card.is_a?(Card)

        @cards << card
      end

      def cards
        @cards.dup
      end

      def total
        score.fetch(:total)
      end

      def soft?
        score.fetch(:soft)
      end

      def blackjack?
        @cards.size == 2 && total == 21
      end

      def busted?
        total > 21
      end

      private

      def score
        total = @cards.sum { |card| value(card) }
        aces = @cards.count { |card| card.rank == "A" }

        while total > 21 && aces.positive?
          total -= 10
          aces -= 1
        end

        { total: total, soft: aces.positive? }
      end

      def value(card)
        case card.rank
        when "A" then 11
        when "J", "Q", "K" then 10
        else card.rank
        end
      end
    end
  end
end
