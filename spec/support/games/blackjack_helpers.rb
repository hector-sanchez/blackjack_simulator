# frozen_string_literal: true

module Games
  module BlackjackHelpers
    def card(rank, suit: "spades")
      Games::Blackjack::Card.new(rank: rank, suit: suit)
    end

    def deck_with(*cards)
      Games::Blackjack::Deck.new(cards: cards)
    end
  end
end
