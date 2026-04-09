require "rails_helper"

RSpec.describe Transactions::DateRange do
  include ActiveSupport::Testing::TimeHelpers

  describe ".resolve" do
    around do |example|
      travel_to(Date.new(2026, 4, 8)) { example.run }
    end

    it "returns the current week range" do
      range = described_class.resolve(period: "week", reference_date: Date.new(2026, 4, 8))

      expect(range).to eq(Date.new(2026, 4, 6)..Date.new(2026, 4, 12))
    end

    it "returns the current month range" do
      range = described_class.resolve(period: "month", reference_date: Date.new(2026, 4, 8))

      expect(range).to eq(Date.new(2026, 4, 1)..Date.new(2026, 4, 30))
    end

    it "returns the current quarter range" do
      range = described_class.resolve(period: "quarter", reference_date: Date.new(2026, 4, 8))

      expect(range).to eq(Date.new(2026, 4, 1)..Date.new(2026, 6, 30))
    end

    it "returns the first semester range when the reference month is in the first half" do
      range = described_class.resolve(period: "semester", reference_date: Date.new(2026, 4, 8))

      expect(range).to eq(Date.new(2026, 1, 1)..Date.new(2026, 6, 30))
    end

    it "returns the second semester range when the reference month is in the second half" do
      range = described_class.resolve(period: "semester", reference_date: Date.new(2026, 10, 18))

      expect(range).to eq(Date.new(2026, 7, 1)..Date.new(2026, 12, 31))
    end

    it "returns the current year range" do
      range = described_class.resolve(period: "year", reference_date: Date.new(2026, 4, 8))

      expect(range).to eq(Date.new(2026, 1, 1)..Date.new(2026, 12, 31))
    end

    it "defaults to the current month when the period is invalid" do
      range = described_class.resolve(period: "invalid")

      expect(range).to eq(Date.new(2026, 4, 1)..Date.new(2026, 4, 30))
    end
  end
end
