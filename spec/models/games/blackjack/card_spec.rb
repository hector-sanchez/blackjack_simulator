# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Card do
  describe "#initialize" do
    it "raises an error if the suit is invalid" do
      expect { Games::Blackjack::Card.new(suit: "invalid", rank: 2) }.to raise_error(ArgumentError)
    end

    it "raises an error if the rank is invalid" do
      expect { Games::Blackjack::Card.new(suit: "hearts", rank: "invalid") }.to raise_error(ArgumentError)
    end

    context "with a valid suit and rank" do
      for suit in Games::Blackjack::Card::SUITS do
        for rank in Games::Blackjack::Card::RANKS do
          it "creates a card with a valid suit and rank" do
            card = Games::Blackjack::Card.new(suit: suit, rank: rank)
            expect(card.suit).to eq(suit)
            expect(card.rank).to eq(rank)
          end
        end
      end
    end
  end

  it "has a valid suit" do
    expect(Games::Blackjack::Card::SUITS).to eq(%w[hearts diamonds clubs spades])
  end

  it "has a valid rank" do
    expect(Games::Blackjack::Card::RANKS).to eq((2..10).to_a + %w[J Q K A])
  end

  it "is equal to another card with the same suit and rank" do
    expect(Games::Blackjack::Card.new(suit: "hearts", rank: 10)).to eq(
      Games::Blackjack::Card.new(suit: "hearts", rank: 10)
    )
  end
end
