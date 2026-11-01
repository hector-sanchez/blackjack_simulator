# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::SessionManager do
  def create_session(deck:)
    game = Games::Blackjack::Game.new(deck: deck)
    game.start!

    GameSession.create!(
      state: Games::Blackjack::GameSerializer.new(game).to_snapshot_h,
      status: game.finished? ? "completed" : "active"
    )
  end

  describe "invalid actions" do
    it "does not modify a completed session" do
      session = create_session(
        deck: deck_with(
          card("A"), card(9),
          card("K"), card(7)
        )
      )

      original_state = session.state.deep_dup

      expect {
        described_class.hit!(session)
      }.to raise_error(Games::Blackjack::Game::InvalidActionError)

      expect(session.reload.state).to eq(original_state)
      expect(session).to be_completed
    end
  end

  describe ".start!" do
    it "creates and persists a Blackjack game session" do
      expect {
        described_class.start!
      }.to change(GameSession, :count).by(1)

      session = GameSession.last

      expect(session.state).to be_present

      game = Games::Blackjack::GameSerializer.load(session.state)

      expect(game.state).not_to eq(:pending)
      expect(game.player_hand.cards.size).to eq(2)
      expect(game.dealer_hand.cards.size).to eq(2)
      expect(session.status).to eq(game.finished? ? "completed" : "active")
    end
  end

  describe ".load" do
    it "restores a persisted Blackjack game" do
      session = described_class.start!

      game = described_class.load(session.reload)

      expect(game).to be_a(Games::Blackjack::Game)
      expect(game.player_hand.cards.size).to eq(2)
      expect(game.dealer_hand.cards.size).to eq(2)
      expect(game.state.to_s).to eq(session.state["state"])
    end
  end

  describe ".hit!" do
    it "executes a hit and persists the updated game" do
      # Deal: player 10, dealer 9, player 7, dealer 6. Hit: 4.
      session = create_session(deck: deck_with(card(10), card(9), card(7), card(6), card(4)))

      described_class.hit!(session)

      restored = described_class.load(session.reload)

      expect(restored.player_hand.cards).to eq([ card(10), card(7), card(4) ])
      expect(restored.remaining_cards).to eq([])
      expect(session.status).to eq("active")
    end
  end

  describe ".stand!" do
    it "executes a stand and persists the updated game" do
      # Deal: player 10, dealer 9, player 9, dealer 6. Dealer hit: K (bust).
      session = create_session(deck: deck_with(card(10), card(9), card(9), card(6), card("K")))

      described_class.stand!(session)

      restored = described_class.load(session.reload)

      expect(restored.player_hand.cards).to eq([ card(10), card(9) ])
      expect(restored.dealer_hand.cards).to eq([ card(9), card(6), card("K") ])
      expect(restored).to be_finished
      expect(restored.outcome).to eq(:player_win)
      expect(session.status).to eq("completed")
    end
  end
end
