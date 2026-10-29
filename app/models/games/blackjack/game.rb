# frozen_string_literal: true

module Games
  module Blackjack
    # Assumes the injected deck has enough cards for the round.
    # If the deck runs out mid-deal, Game does not roll back partial hands.
    class Game
      class InvalidActionError < StandardError; end

      attr_reader :state, :outcome

      def initialize(deck: nil)
        @deck = deck || Deck.new.tap(&:shuffle!)
        @player_hand = Hand.new
        @dealer_hand = Hand.new
        @state = :pending
        @outcome = nil
      end

      def player_hand
        Hand.new(@player_hand.cards)
      end

      def dealer_hand
        Hand.new(@dealer_hand.cards)
      end

      def start!
        require_state!(:pending)

        2.times do
          @player_hand.add_card(@deck.draw)
          @dealer_hand.add_card(@deck.draw)
        end

        if @player_hand.blackjack? || @dealer_hand.blackjack?
          finish!(Rules.outcome(@player_hand, @dealer_hand))
        else
          @state = :player_turn
        end
      end

      def hit!
        require_player_action!(:hit)

        @player_hand.add_card(@deck.draw)
        finish!(:dealer_win) if @player_hand.busted?
      end

      def stand!
        require_player_action!(:stand)

        @dealer_hand.add_card(@deck.draw) while Rules.dealer_hits?(@dealer_hand)
        finish!(Rules.outcome(@player_hand, @dealer_hand))
      end

      def legal_actions
        return [] unless @state == :player_turn

        Rules.legal_actions(@player_hand)
      end

      def finished?
        @state == :finished
      end

      def visible_dealer_cards
        return [] if @state == :pending
        return @dealer_hand.cards if finished?

        [ @dealer_hand.cards.first ]
      end

      private

      def require_player_action!(action)
        require_state!(:player_turn)
        raise InvalidActionError unless legal_actions.include?(action)
      end

      def require_state!(expected)
        raise InvalidActionError unless @state == expected
      end

      def finish!(result)
        @outcome = result
        @state = :finished
      end
    end
  end
end
