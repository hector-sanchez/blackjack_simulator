# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Blackjack::Deck do
  subject { described_class.new }

  def draw_all(deck = subject)
    Array.new(deck.remaining) { deck.draw }
  end

  it 'has 52 cards' do
    expect(subject.remaining).to eq(52)
  end

  it 'has 4 suits' do
    expect(draw_all.map(&:suit).uniq.count).to eq(4)
  end

  it 'has 13 ranks' do
    expect(draw_all.map(&:rank).uniq.count).to eq(13)
  end

  describe '#shuffle!' do
    it 'shuffles the cards' do
      unshuffled = described_class.new

      subject.shuffle!

      shuffled_order = draw_all.map { |card| [ card.suit, card.rank ] }
      original_order = draw_all(unshuffled).map { |card| [ card.suit, card.rank ] }

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
