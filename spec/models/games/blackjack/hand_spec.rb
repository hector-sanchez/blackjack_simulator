# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Blackjack::Hand do
  def hand_with(*ranks)
    described_class.new(ranks.map { |rank| card(rank) })
  end

  describe '#initialize' do
    it 'starts empty by default' do
      hand = described_class.new

      expect(hand.cards).to eq([])
      expect(hand.total).to eq(0)
    end

    it 'raises ArgumentError when the collection contains nil' do
      expect { described_class.new([ nil ]) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when the collection contains a non-card' do
      expect { described_class.new([ 'A' ]) }.to raise_error(ArgumentError)
    end
  end

  describe '#cards' do
    it 'returns the cards the hand was initialized with' do
      ten = card(10)
      seven = card(7)
      hand = described_class.new([ ten, seven ])

      expect(hand.cards).to eq([ ten, seven ])
    end

    it 'returns no cards for an empty hand' do
      expect(described_class.new.cards).to eq([])
    end

    it 'does not let callers mutate the hand through the public reader' do
      ten = card(10)
      seven = card(7)
      hand = described_class.new([ ten, seven ])

      hand.cards << card('A')

      expect(hand.cards).to eq([ ten, seven ])
      expect(hand.total).to eq(17)
    end

    it 'does not let the original cards array mutate the hand' do
      ten = card(10)
      seven = card(7)
      cards = [ ten, seven ]
      hand = described_class.new(cards)

      cards.clear

      expect(hand.cards).to eq([ ten, seven ])
      expect(hand.total).to eq(17)
    end
  end

  describe '#add_card' do
    it 'adds a card to the hand' do
      ten = card(10)
      seven = card(7)
      hand = described_class.new([ ten ])

      hand.add_card(seven)

      expect(hand.cards).to eq([ ten, seven ])
    end

    it 'adds a card to an empty hand' do
      ace = card('A')
      hand = described_class.new

      hand.add_card(ace)

      expect(hand.cards).to eq([ ace ])
    end

    it 'raises ArgumentError when given nil' do
      hand = described_class.new

      expect { hand.add_card(nil) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when given a non-card' do
      hand = described_class.new

      expect { hand.add_card('A') }.to raise_error(ArgumentError)
    end
  end

  describe 'scoring' do
    [
      { ranks: [], total: 0, soft: false, blackjack: false, busted: false },
      { ranks: [ 10, 7 ], total: 17, soft: false, blackjack: false, busted: false },
      { ranks: [ 'A', 7 ], total: 18, soft: true, blackjack: false, busted: false },
      { ranks: [ 'A', 7, 9 ], total: 17, soft: false, blackjack: false, busted: false },
      { ranks: [ 'A', 'A' ], total: 12, soft: true, blackjack: false, busted: false },
      { ranks: [ 'A', 'A', 9 ], total: 21, soft: true, blackjack: false, busted: false },
      { ranks: [ 'A', 'K' ], total: 21, soft: true, blackjack: true, busted: false },
      { ranks: [ 7, 9, 5 ], total: 21, soft: false, blackjack: false, busted: false },
      { ranks: [ 'K', 'Q', 5 ], total: 25, soft: false, blackjack: false, busted: true },
      { ranks: [ 'A' ], total: 11, soft: true, blackjack: false, busted: false },
      { ranks: [ 'A', 10 ], total: 21, soft: true, blackjack: true, busted: false },
      { ranks: [ 'A', 'A', 'A' ], total: 13, soft: true, blackjack: false, busted: false },
      { ranks: [ 'A', 'A', 9, 'K' ], total: 21, soft: false, blackjack: false, busted: false },
      { ranks: [ 'A', 9, 'K', 5 ], total: 25, soft: false, blackjack: false, busted: true },
      { ranks: [ 10, 'A', 'K' ], total: 21, soft: false, blackjack: false, busted: false }
    ].each do |scenario|
      ranks = scenario[:ranks]
      label = ranks.empty? ? 'no cards' : ranks.join(', ')

      describe "with #{label}" do
        subject(:hand) { hand_with(*ranks) }

        it "has a total of #{scenario[:total]}" do
          expect(hand.total).to eq(scenario[:total])
        end

        it "is #{'not ' unless scenario[:soft]}soft" do
          expect(hand.soft?).to eq(scenario[:soft])
        end

        it "is #{'not ' unless scenario[:blackjack]}blackjack" do
          expect(hand.blackjack?).to eq(scenario[:blackjack])
        end

        it "is #{'not ' unless scenario[:busted]}busted" do
          expect(hand.busted?).to eq(scenario[:busted])
        end
      end
    end
  end
end
