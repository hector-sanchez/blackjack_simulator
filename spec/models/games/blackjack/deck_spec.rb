# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Blackjack::Deck do
  subject { described_class.new }

  def card(rank, suit: 'hearts')
    Games::Blackjack::Card.new(suit: suit, rank: rank)
  end

  def draw_all(deck = subject)
    Array.new(deck.remaining) { deck.draw }
  end

  describe '#initialize' do
    it 'builds a standard 52-card deck by default' do
      expect(subject.remaining).to eq(52)
    end

    it 'uses the provided cards' do
      ace = card('A')
      ten = card(10)
      deck = described_class.new(cards: [ ace, ten ])

      expect(deck.cards).to eq([ ace, ten ])
      expect(deck.draw).to eq(ace)
      expect(deck.draw).to eq(ten)
      expect(deck).to be_empty
    end
  end

  describe '#cards' do
    it 'has 52 cards' do
      expect(subject.cards.count).to eq(52)
    end

    it 'has 4 suits' do
      expect(subject.cards.map(&:suit).uniq.count).to eq(4)
    end

    it 'has 13 ranks' do
      expect(subject.cards.map(&:rank).uniq.count).to eq(13)
    end

    it 'does not let callers mutate the deck through the reader' do
      subject.cards.clear

      expect(subject.remaining).to eq(52)
    end
  end

  describe '#shuffle!' do
    it 'shuffles the cards' do
      original_order = subject.cards.map { |c| [ c.suit, c.rank ] }

      subject.shuffle!

      shuffled_order = subject.cards.map { |c| [ c.suit, c.rank ] }
      expect(shuffled_order).not_to eq(original_order)
    end
  end

  describe '#draw' do
    it 'draws a card' do
      expect(subject.draw).to be_a(Games::Blackjack::Card)
    end

    it 'raises an error if the deck is empty' do
      draw_all
      expect { subject.draw }.to raise_error(Games::Blackjack::Deck::EmptyError)
    end
  end

  describe '#remaining' do
    it 'returns the number of cards remaining in the deck' do
      expect(subject.remaining).to eq(52)
    end

    it 'decreases the number of cards remaining in the deck' do
      subject.draw
      expect(subject.remaining).to eq(51)
    end
  end

  describe '#empty?' do
    it 'returns true if the deck is empty' do
      expect(subject.empty?).to be_falsey
    end

    it 'empties the deck' do
      draw_all
      expect(subject.empty?).to be_truthy
    end
  end
end
