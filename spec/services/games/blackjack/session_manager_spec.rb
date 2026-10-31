# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::SessionManager do
  describe ".start!" do
    it "creates and persists a Blackjack game session" do
      expect {
        described_class.start!
      }.to change(GameSession, :count).by(1)

      session = GameSession.last

      expect(session.game_type).to eq("blackjack")
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
      session = described_class.start!
      game = described_class.load(session)

      # A natural blackjack can finish immediately.
      # This example requires a session in player_turn.
      skip "Initial game finished" if game.finished?

      initial_count = game.player_hand.cards.size

      described_class.hit!(session)

      restored = described_class.load(session.reload)

      expect(restored.player_hand.cards.size).to eq(initial_count + 1)
      expect(restored.remaining_cards.size).to eq(47)
    end
  end

  describe ".stand!" do
    it "executes a stand and persists the updated game" do
      session = described_class.start!
      game = described_class.load(session)

      # A natural blackjack can finish immediately.
      # This example requires a session in player_turn.
      skip "Initial game finished" if game.finished?

      initial_count = game.player_hand.cards.size

      described_class.stand!(session)

      restored = described_class.load(session.reload)

      expect(restored.player_hand.cards.size).to eq(initial_count)
      expect(restored.dealer_hand.cards.size).to be >= 2
      expect(restored).to be_finished
      expect(restored.outcome).to be_present
      expect(session.status).to eq("completed")
    end
  end
end
