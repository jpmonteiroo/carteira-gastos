require "rails_helper"

RSpec.describe Transactions::Filters::DatePeriod do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, user: user) }
  let(:category) { create(:category, :expense, user: user) }

  subject(:filtered_scope) { described_class.apply(Transaction.where(wallet: wallet), filters) }

  around do |example|
    travel_to(Date.new(2026, 4, 8)) { example.run }
  end

  describe ".apply" do
    context "when the period filter is blank" do
      let(:filters) { {} }

      it "returns the original scope" do
        in_month = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 4, 4))
        out_month = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 3, 20))

        expect(filtered_scope).to match_array([ in_month, out_month ])
      end
    end

    context "when the period filter is invalid" do
      let(:filters) { { period: "invalid" } }

      it "returns the original scope" do
        in_month = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 4, 4))
        out_month = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 3, 20))

        expect(filtered_scope).to match_array([ in_month, out_month ])
      end
    end

    context "when filtering by week" do
      let(:filters) { { period: "week" } }

      it "keeps only the transactions from the current week" do
        in_week = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 4, 7))
        out_week = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 4, 2))

        expect(filtered_scope).to match_array([ in_week ])
        expect(filtered_scope).not_to include(out_week)
      end
    end

    context "when filtering by month" do
      let(:filters) { { period: "month" } }

      it "keeps only the transactions from the current month" do
        in_month = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 4, 2))
        out_month = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 3, 31))

        expect(filtered_scope).to match_array([ in_month ])
        expect(filtered_scope).not_to include(out_month)
      end
    end

    context "when filtering by quarter" do
      let(:filters) { { period: "quarter" } }

      it "keeps only the transactions from the current quarter" do
        in_quarter = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 5, 15))
        out_quarter = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 3, 31))

        expect(filtered_scope).to match_array([ in_quarter ])
        expect(filtered_scope).not_to include(out_quarter)
      end
    end

    context "when filtering by semester" do
      let(:filters) { { period: "semester" } }

      it "keeps only the transactions from the current semester" do
        in_semester = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 6, 30))
        out_semester = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 7, 1))

        expect(filtered_scope).to match_array([ in_semester ])
        expect(filtered_scope).not_to include(out_semester)
      end
    end

    context "when filtering by year" do
      let(:filters) { { period: "year" } }

      it "keeps only the transactions from the current year" do
        in_year = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2026, 12, 31))
        out_year = create(:transaction, user: user, wallet: wallet, category: category, date: Date.new(2025, 12, 31))

        expect(filtered_scope).to match_array([ in_year ])
        expect(filtered_scope).not_to include(out_year)
      end
    end
  end
end
