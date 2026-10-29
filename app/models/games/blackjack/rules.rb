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
          return :dealer_win if player_hand.busted?
          return :player_win if dealer_hand.busted?

          if player_hand.blackjack? != dealer_hand.blackjack?
            return player_hand.blackjack? ? :player_win : :dealer_win
          end

          case player_hand.total <=> dealer_hand.total
          when 1 then :player_win
          when -1 then :dealer_win
          else :push
          end
        end
      end
    end
  end
end
