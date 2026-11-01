# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Games", type: :request do
  describe "GET /" do
    it "renders the games index" do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
