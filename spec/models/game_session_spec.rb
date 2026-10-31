# frozen_string_literal: true

require "rails_helper"

RSpec.describe GameSession, type: :model do
  def valid_attributes
    {
      state: { "any" => "payload" },
      status: "active"
    }
  end

  it "is valid with a nonempty state hash and status" do
    expect(described_class.new(valid_attributes)).to be_valid
  end

  it "requires a state" do
    session = described_class.new(valid_attributes.merge(state: nil))

    expect(session).not_to be_valid
    expect(session.errors[:state]).to be_present
  end

  it "requires a nonempty state hash" do
    session = described_class.new(valid_attributes.merge(state: {}))

    expect(session).not_to be_valid
    expect(session.errors[:state]).to be_present
  end

  it "requires a status" do
    session = described_class.new(valid_attributes.merge(status: nil))

    expect(session).not_to be_valid
    expect(session.errors[:status]).to be_present
  end

  describe "status" do
    it "defines active and completed" do
      expect(described_class.statuses).to eq("active" => "active", "completed" => "completed")
    end

    it "defaults to active" do
      session = described_class.create!(valid_attributes.except(:status))

      expect(session).to be_active
    end

    it "can be completed" do
      session = described_class.create!(valid_attributes.merge(status: "completed"))

      expect(session).to be_completed
    end

    it "rejects unsupported statuses" do
      expect {
        described_class.new(valid_attributes.merge(status: "unknown"))
      }.to raise_error(ArgumentError)
    end
  end

  it "persists a nonempty jsonb state hash" do
    session = described_class.create!(valid_attributes)

    expect(session.reload.state).to eq(valid_attributes[:state])
  end
end
