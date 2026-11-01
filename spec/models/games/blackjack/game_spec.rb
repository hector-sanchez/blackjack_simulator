# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Blackjack::Game do
  def pending_game
    described_class.new(deck: Games::Blackjack::Deck.new(cards: []))
  end

  def game_with(*cards)
    described_class.new(deck: deck_with(*cards))
  end

  describe '#initialize' do
    subject(:game) { pending_game }

    it 'starts pending with empty hands' do
      expect(game.state).to eq(:pending)
      expect(game.player_hand.cards).to eq([])
      expect(game.dealer_hand.cards).to eq([])
      expect(game.finished?).to eq(false)
      expect(game.outcome).to eq(nil)
    end
  end

  describe '.restore' do
    it 'rebuilds a mid-turn game without dealing' do
      leftover = card(3)
      player_ten = card(10)
      player_seven = card(7)
      dealer_nine = card(9)
      dealer_six = card(6)
      game = described_class.restore(
        deck: deck_with(leftover),
        player_hand: Games::Blackjack::Hand.new([ player_ten, player_seven ]),
        dealer_hand: Games::Blackjack::Hand.new([ dealer_nine, dealer_six ]),
        state: :player_turn,
        outcome: nil
      )

      expect(game.state).to eq(:player_turn)
      expect(game.player_hand.cards).to eq([ player_ten, player_seven ])
      expect(game.dealer_hand.cards).to eq([ dealer_nine, dealer_six ])
      expect(game.remaining_cards).to eq([ leftover ])
      expect(game.outcome).to eq(nil)
    end

    it 'draws the next remaining card on hit' do
      extra = card(3)
      game = described_class.restore(
        deck: deck_with(extra),
        player_hand: Games::Blackjack::Hand.new([ card(10), card(2) ]),
        dealer_hand: Games::Blackjack::Hand.new([ card(9), card(8) ]),
        state: :player_turn,
        outcome: nil
      )

      game.hit!

      expect(game.player_hand.cards.last).to eq(extra)
      expect(game.state).to eq(:player_turn)
    end

    it 'keeps a finished round finished' do
      game = described_class.restore(
        deck: deck_with,
        player_hand: Games::Blackjack::Hand.new([ card('A'), card('K') ]),
        dealer_hand: Games::Blackjack::Hand.new([ card(9), card(7) ]),
        state: :finished,
        outcome: :player_win
      )

      expect(game.finished?).to eq(true)
      expect(game.outcome).to eq(:player_win)
      expect { game.start! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
      expect { game.hit! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
    end
  end

  describe '#start!' do
    it 'deals two cards to each participant in alternating order' do
      player_first = card(10)
      dealer_upcard = card(9)
      player_second = card(7)
      dealer_hole = card(6)
      game = game_with(player_first, dealer_upcard, player_second, dealer_hole)

      game.start!

      expect(game.player_hand.cards).to eq([ player_first, player_second ])
      expect(game.dealer_hand.cards).to eq([ dealer_upcard, dealer_hole ])
      expect(game.state).to eq(:player_turn)
    end

    it 'finishes immediately when the player has a natural blackjack' do
      ace = card('A', suit: 'spades')
      nine = card(9, suit: 'hearts')
      king = card('K', suit: 'clubs')
      seven = card(7, suit: 'diamonds')
      game = game_with(ace, nine, king, seven)

      game.start!

      expect(game.player_hand.cards).to eq([ ace, king ])
      expect(game.dealer_hand.cards).to eq([ nine, seven ])
      expect(game.state).to eq(:finished)
      expect(game.finished?).to eq(true)
      expect(game.outcome).to eq(:player_win)
    end

    it 'finishes immediately when the dealer has a natural blackjack' do
      game = game_with(card(10), card('A'), card(9), card('K'))

      game.start!

      expect(game.player_hand.blackjack?).to eq(false)
      expect(game.dealer_hand.blackjack?).to eq(true)
      expect(game.state).to eq(:finished)
      expect(game.outcome).to eq(:dealer_win)
    end

    it 'finishes as a push when both have a natural blackjack' do
      game = game_with(card('A'), card('A', suit: 'hearts'), card('K'), card(10, suit: 'hearts'))

      game.start!

      expect(game.state).to eq(:finished)
      expect(game.outcome).to eq(:push)
    end

    it 'rejects starting twice' do
      game = game_with(card(10), card(9), card(7), card(6))
      game.start!

      expect { game.start! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
    end
  end

  describe '#hit!' do
    it 'adds one card to the player hand and continues the player turn' do
      extra = card(3)
      game = game_with(card(10), card(9), card(2), card(8), extra)
      game.start!

      game.hit!

      expect(game.player_hand.cards.last).to eq(extra)
      expect(game.state).to eq(:player_turn)
      expect(game.finished?).to eq(false)
    end

    it 'finishes with a dealer win when the player busts' do
      game = game_with(card(10), card(9), card(6), card(8), card('K'))
      game.start!

      game.hit!

      expect(game.state).to eq(:finished)
      expect(game.outcome).to eq(:dealer_win)
    end

    it 'rejects a hit before the game has started' do
      game = pending_game

      expect { game.hit! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
    end

    it 'rejects a hit after the round has finished' do
      game = game_with(card('A'), card(9), card('K'), card(7))
      game.start!

      expect { game.hit! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
    end
  end

  describe '#stand!' do
    it 'lets the dealer draw until the total is 17 or higher' do
      dealer_hit = card(5)
      game = game_with(card(10), card(10), card(9), card(6), dealer_hit)
      game.start!

      game.stand!

      expect(game.dealer_hand.cards.last).to eq(dealer_hit)
      expect(game.dealer_hand.total).to eq(21)
      expect(game.state).to eq(:finished)
    end

    it 'finishes with a player win when the dealer busts' do
      game = game_with(card(10), card(10), card(9), card(6), card('K'))
      game.start!

      game.stand!

      expect(game.outcome).to eq(:player_win)
      expect(game.finished?).to eq(true)
    end

    it 'finishes as a push when totals are equal' do
      game = game_with(card(10), card(10), card(9), card(9))
      game.start!

      game.stand!

      expect(game.outcome).to eq(:push)
    end

    it 'rejects a stand after the round has finished' do
      game = game_with(card('A'), card(9), card('K'), card(7))
      game.start!

      expect { game.stand! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
    end
  end

  describe '#legal_actions' do
    it 'returns no actions when the game is not the player turn' do
      game = pending_game
      expect(game.legal_actions).to eq([])

      finished = game_with(card('A'), card(9), card('K'), card(7))
      finished.start!
      expect(finished.legal_actions).to eq([])
    end

    it 'delegates to the rules during the player turn' do
      game = game_with(card(10), card(9), card(7), card(6))
      game.start!

      expect(game.legal_actions).to eq([ :hit, :stand ])
    end
  end

  describe '#remaining_cards' do
    it 'returns the undealt cards' do
      player_first = card(10)
      dealer_upcard = card(9)
      player_second = card(7)
      dealer_hole = card(6)
      leftover = card(2)
      game = game_with(player_first, dealer_upcard, player_second, dealer_hole, leftover)

      expect(game.remaining_cards).to eq([ player_first, dealer_upcard, player_second, dealer_hole, leftover ])

      game.start!

      expect(game.remaining_cards).to eq([ leftover ])
    end

    it 'does not let callers mutate the remaining deck through the reader' do
      leftover = card(2)
      game = game_with(card(10), card(9), card(7), card(6), leftover)
      game.start!

      game.remaining_cards.clear

      expect(game.remaining_cards).to eq([ leftover ])
    end
  end

  describe '#visible_dealer_cards' do
    it 'hides the hole card until the round finishes' do
      upcard = card(10)
      hole = card(7)
      game = game_with(card(10, suit: 'hearts'), upcard, card(8), hole)
      game.start!

      expect(game.visible_dealer_cards).to eq([ upcard ])
      expect(game.dealer_hand.cards).to eq([ upcard, hole ])

      game.stand!

      expect(game.visible_dealer_cards).to eq([ upcard, hole ])
    end
  end
end
