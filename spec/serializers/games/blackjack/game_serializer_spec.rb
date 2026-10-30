# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Blackjack::GameSerializer do
  def card(rank, suit: 'spades')
    Games::Blackjack::Card.new(suit: suit, rank: rank)
  end

  def card_hash(card)
    { suit: card.suit, rank: card.rank }
  end

  it 'serializes a pending game' do
    remaining = card(2)
    game = Games::Blackjack::Game.new(deck: Games::Blackjack::Deck.new(cards: [ remaining ]))

    expect(described_class.new(game).to_h).to eq(
      state: 'pending',
      outcome: nil,
      player_cards: [],
      dealer_cards: [],
      remaining_cards: [ card_hash(remaining) ]
    )
  end

  it 'serializes hands and the remaining deck after the deal' do
    player_first = card(10)
    dealer_upcard = card(9)
    player_second = card(7)
    dealer_hole = card(6)
    leftover = card(2)
    game = Games::Blackjack::Game.new(
      deck: Games::Blackjack::Deck.new(
        cards: [ player_first, dealer_upcard, player_second, dealer_hole, leftover ]
      )
    )
    serializer = described_class.new(game)
    game.start!

    expect(serializer.to_h).to eq(
      state: 'player_turn',
      outcome: nil,
      player_cards: [ card_hash(player_first), card_hash(player_second) ],
      dealer_cards: [ card_hash(dealer_upcard), card_hash(dealer_hole) ],
      remaining_cards: [ card_hash(leftover) ]
    )
  end

  it 'serializes a finished outcome' do
    game = Games::Blackjack::Game.new(
      deck: Games::Blackjack::Deck.new(
        cards: [ card('A'), card(9), card('K'), card(7) ]
      )
    )
    serializer = described_class.new(game)
    game.start!

    expect(serializer.to_h).to include(
      state: 'finished',
      outcome: 'player_win'
    )
  end

  describe '.load' do
    it 'restores a serialized game without losing state' do
      leftover = card(2)
      game = Games::Blackjack::Game.new(
        deck: Games::Blackjack::Deck.new(
          cards: [ card(10), card(9), card(7), card(6), leftover ]
        )
      )
      game.start!

      snapshot = described_class.new(game).to_h.deep_stringify_keys
      restored = described_class.load(snapshot)

      expect(restored.state).to eq(game.state)
      expect(restored.player_hand.cards).to eq(game.player_hand.cards)
      expect(restored.dealer_hand.cards).to eq(game.dealer_hand.cards)
      expect(restored.remaining_cards).to eq(game.remaining_cards)
    end

    it 'lets a restored game continue accepting legal actions' do
      extra = card(3)
      game = Games::Blackjack::Game.new(
        deck: Games::Blackjack::Deck.new(
          cards: [ card(10), card(9), card(2), card(8), extra ]
        )
      )
      game.start!
      restored = described_class.load(described_class.new(game).to_h.deep_stringify_keys)

      restored.hit!

      expect(restored.player_hand.cards.last).to eq(extra)
      expect(restored.state).to eq(:player_turn)
    end

    it 'retains the outcome of a finished game' do
      game = Games::Blackjack::Game.new(
        deck: Games::Blackjack::Deck.new(
          cards: [ card('A'), card(9), card('K'), card(7) ]
        )
      )
      game.start!
      restored = described_class.load(described_class.new(game).to_h.deep_stringify_keys)

      expect(restored.finished?).to eq(true)
      expect(restored.outcome).to eq(:player_win)
      expect { restored.hit! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
    end
  end
end
