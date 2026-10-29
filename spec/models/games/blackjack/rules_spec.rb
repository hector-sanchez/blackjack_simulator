# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Blackjack::Rules do
  def card(rank)
    Games::Blackjack::Card.new(suit: 'hearts', rank: rank)
  end

  def hand(*ranks)
    Games::Blackjack::Hand.new(ranks.map { |rank| card(rank) })
  end

  describe '.legal_actions' do
    it 'allows hit and stand below 21' do
      expect(described_class.legal_actions(hand(10, 7))).to eq([ :hit, :stand ])
    end

    it 'prevents hit at 21' do
      expect(described_class.legal_actions(hand(7, 9, 5))).to eq([ :stand ])
    end

    it 'prevents actions after bust' do
      expect(described_class.legal_actions(hand('K', 'Q', 5))).to eq([])
    end

    it 'prevents actions after natural blackjack' do
      expect(described_class.legal_actions(hand('A', 'K'))).to eq([])
    end
  end

  describe '.dealer_hits?' do
    it 'hits below 17' do
      expect(described_class.dealer_hits?(hand(10, 6))).to eq(true)
    end

    it 'hits on soft 16' do
      expect(described_class.dealer_hits?(hand('A', 5))).to eq(true)
    end

    it 'stands on hard 17' do
      expect(described_class.dealer_hits?(hand(10, 7))).to eq(false)
    end

    it 'stands on soft 17' do
      expect(described_class.dealer_hits?(hand('A', 6))).to eq(false)
    end

    it 'stands above 17' do
      expect(described_class.dealer_hits?(hand(10, 8))).to eq(false)
    end
  end

  describe '.outcome' do
    it 'resolves player bust' do
      expect(described_class.outcome(hand('K', 'Q', 2), hand(10, 8))).to eq(:dealer_win)
    end

    it 'resolves player bust even when the dealer also busts' do
      expect(described_class.outcome(hand('K', 'Q', 2), hand('K', 'Q', 4))).to eq(:dealer_win)
    end

    it 'resolves dealer bust' do
      expect(described_class.outcome(hand(10, 10), hand('K', 'Q', 3))).to eq(:player_win)
    end

    it 'resolves higher player total' do
      expect(described_class.outcome(hand(10, 10), hand(10, 8))).to eq(:player_win)
    end

    it 'resolves higher dealer total' do
      expect(described_class.outcome(hand(10, 8), hand(10, 10))).to eq(:dealer_win)
    end

    it 'resolves equal totals' do
      expect(described_class.outcome(hand(10, 9), hand(10, 9))).to eq(:push)
    end

    it 'resolves player natural blackjack over ordinary 21' do
      expect(described_class.outcome(hand('A', 'K'), hand(7, 9, 5))).to eq(:player_win)
    end

    it 'resolves dealer natural blackjack over ordinary 21' do
      expect(described_class.outcome(hand(7, 9, 5), hand('A', 'K'))).to eq(:dealer_win)
    end

    it 'resolves simultaneous naturals' do
      expect(described_class.outcome(hand('A', 'K'), hand('A', 10))).to eq(:push)
    end
  end
end
