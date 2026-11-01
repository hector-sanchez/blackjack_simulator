# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Blackjack::Sessions", type: :request do
  def persist_owned_game(*ranks)
    game = Games::Blackjack::Game.new(deck: deck_with(*ranks.map { |rank| card(rank) }))
    game.start!

    post blackjack_sessions_path
    game_session = GameSession.last
    game_session.update!(
      state: Games::Blackjack::GameSerializer.new(game).to_snapshot_h,
      status: game.finished? ? "completed" : "active"
    )
    game_session
  end

  describe "POST /blackjack/sessions" do
    it "starts a game, stores the session id, and redirects" do
      expect {
        post blackjack_sessions_path
      }.to change(GameSession, :count).by(1)

      game_session = GameSession.last

      expect(session[:game_session_id]).to eq(game_session.id)
      expect(response).to redirect_to(blackjack_session_path(game_session))
    end
  end

  describe "GET /blackjack/sessions/:id" do
    it "shows the public game and hides the hole card and remaining shoe" do
      game_session = persist_owned_game(10, 9, 7, 6, 2)

      get blackjack_session_path(game_session)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("10 of spades")
      expect(response.body).to include("7 of spades")
      expect(response.body).to include("9 of spades")
      expect(response.body).not_to include("6 of spades")
      expect(response.body).not_to include("2 of spades")
    end

    it "does not show a session the player does not own" do
      persist_owned_game(10, 9, 7, 6, 2)
      other = GameSession.create!(
        state: { "any" => "payload" },
        status: "active"
      )

      get blackjack_session_path(other)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /blackjack/sessions/:id/hit" do
    it "hits and redirects to the session" do
      game_session = persist_owned_game(10, 9, 7, 6, 4)

      post hit_blackjack_session_path(game_session)

      expect(response).to redirect_to(blackjack_session_path(game_session))

      restored = Games::Blackjack::SessionManager.load(game_session.reload)
      expect(restored.player_hand.cards.last).to eq(card(4))
    end

    it "does not hit a session the player does not own" do
      persist_owned_game(10, 9, 7, 6, 4)
      other = GameSession.create!(
        state: { "any" => "payload" },
        status: "active"
      )

      post hit_blackjack_session_path(other)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /blackjack/sessions/:id/stand" do
    it "stands and redirects to the session" do
      game_session = persist_owned_game(10, 9, 9, 6, "K")

      post stand_blackjack_session_path(game_session)

      expect(response).to redirect_to(blackjack_session_path(game_session))

      restored = Games::Blackjack::SessionManager.load(game_session.reload)
      expect(restored).to be_finished
      expect(restored.outcome).to eq(:player_win)
    end

    it "does not stand a session the player does not own" do
      persist_owned_game(10, 9, 9, 6, "K")
      other = GameSession.create!(
        state: { "any" => "payload" },
        status: "active"
      )

      post stand_blackjack_session_path(other)

      expect(response).to have_http_status(:not_found)
    end
  end
end
