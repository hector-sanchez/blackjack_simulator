# frozen_string_literal: true

module Games
  module Blackjack
    class Rules
      class << self
        def legal_actions(hand)
          return [] if hand.blackjack? || hand.busted?
          return [ :stand ] if hand.total == 21

          [ :hit, :stand ]
        end

        def dealer_hits?(hand)
          hand.total < 17
        end

        def outcome(player_hand, dealer_hand)
          return :dealer_win if player_hand.busted? || winning_hand?(dealer_hand, player_hand)
          return :player_win if winning_hand?(player_hand, dealer_hand)

          :push
        end

        private

        def winning_hand?(hand, other)
          return false if hand.busted?
          return true if other.busted?
          return hand.blackjack? if hand.blackjack? != other.blackjack?

          hand.total > other.total
        end
      end
    end
  end
end
