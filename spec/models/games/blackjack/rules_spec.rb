# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Blackjack::Rules do
  def hand(*ranks)
    Games::Blackjack::Hand.new(ranks.map { |rank| card(rank) })
  end

  describe '.legal_actions' do
    [
      { ranks: [ 10, 7 ], result: [ :hit, :stand ], case: 'allows hit and stand below 21' },
      { ranks: [ 7, 9, 5 ], result: [ :stand ], case: 'prevents hit at 21' },
      { ranks: [ 'K', 'Q', 5 ], result: [], case: 'prevents actions after bust' },
      { ranks: [ 'A', 'K' ], result: [], case: 'prevents actions after natural blackjack' }
    ].each do |scenario|
      it scenario[:case] do
        expect(described_class.legal_actions(hand(*scenario[:ranks]))).to eq(scenario[:result])
      end
    end
  end

  describe '.dealer_hits?' do
    [
      { ranks: [ 10, 6 ], result: true, case: 'hits below 17' },
      { ranks: [ 'A', 5 ], result: true, case: 'hits on soft 16' },
      { ranks: [ 10, 7 ], result: false, case: 'stands on hard 17' },
      { ranks: [ 'A', 6 ], result: false, case: 'stands on soft 17' },
      { ranks: [ 10, 8 ], result: false, case: 'stands above 17' }
    ].each do |scenario|
      it scenario[:case] do
        expect(described_class.dealer_hits?(hand(*scenario[:ranks]))).to eq(scenario[:result])
      end
    end
  end

  describe '.outcome' do
    [
      { player: [ 'K', 'Q', 2 ], dealer: [ 10, 8 ], result: :dealer_win, case: 'player bust' },
      { player: [ 'K', 'Q', 2 ], dealer: [ 'K', 'Q', 4 ], result: :dealer_win, case: 'player bust even when the dealer also busts' },
      { player: [ 10, 10 ], dealer: [ 'K', 'Q', 3 ], result: :player_win, case: 'dealer bust' },
      { player: [ 10, 10 ], dealer: [ 10, 8 ], result: :player_win, case: 'higher player total' },
      { player: [ 10, 8 ], dealer: [ 10, 10 ], result: :dealer_win, case: 'higher dealer total' },
      { player: [ 10, 9 ], dealer: [ 10, 9 ], result: :push, case: 'equal totals' },
      { player: [ 'A', 'K' ], dealer: [ 7, 9, 5 ], result: :player_win, case: 'player natural blackjack over ordinary 21' },
      { player: [ 7, 9, 5 ], dealer: [ 'A', 'K' ], result: :dealer_win, case: 'dealer natural blackjack over ordinary 21' },
      { player: [ 'A', 'K' ], dealer: [ 'A', 10 ], result: :push, case: 'simultaneous naturals' }
    ].each do |scenario|
      it "resolves #{scenario[:case]}" do
        player_hand = hand(*scenario[:player])
        dealer_hand = hand(*scenario[:dealer])

        expect(described_class.outcome(player_hand, dealer_hand)).to eq(scenario[:result])
      end
    end
  end
end
