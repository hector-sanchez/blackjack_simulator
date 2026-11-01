# frozen_string_literal: true

module Blackjack
  class SessionsController < ApplicationController
    before_action :set_session, only: %i[show hit stand]

    def create
      game_session = Games::Blackjack::SessionManager.start!
      session[:game_session_id] = game_session.id

      redirect_to blackjack_session_path(game_session)
    end

    def show
      game = Games::Blackjack::SessionManager.load(@game_session)
      @game = Games::Blackjack::GameSerializer.new(game).to_public_h
    end

    def hit
      Games::Blackjack::SessionManager.hit!(@game_session)
      redirect_to blackjack_session_path(@game_session)
    rescue Games::Blackjack::Game::InvalidActionError
      redirect_to blackjack_session_path(@game_session), alert: "That action is not allowed."
    end

    def stand
      Games::Blackjack::SessionManager.stand!(@game_session)
      redirect_to blackjack_session_path(@game_session)
    rescue Games::Blackjack::Game::InvalidActionError
      redirect_to blackjack_session_path(@game_session), alert: "That action is not allowed."
    end

    private

    def set_session
      @game_session = GameSession.find(params[:id])

      raise ActiveRecord::RecordNotFound unless session[:game_session_id] == @game_session.id
    end
  end
end
