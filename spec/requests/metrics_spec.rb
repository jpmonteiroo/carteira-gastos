require "rails_helper"

RSpec.describe "Metrics", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let!(:expense_category) { create(:category, :expense, user: user, name: "Moradia") }
  let!(:income_category) { create(:category, :income, user: user, name: "Salario") }

  describe "authentication" do
    it "redirects unauthenticated users from index" do
      get metrics_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /metrics" do
    before { sign_in user }

    around do |example|
      travel_to(Date.new(2026, 4, 8)) { example.run }
    end

    it "defaults to the current month and the initial wallet" do
      first_wallet = create(:wallet, user: user, name: "Carteira principal")
      second_wallet = create(:wallet, user: user, name: "Investimentos")

      current_month_category = create(:category, :expense, user: user, name: "Mercado")
      previous_month_category = create(:category, :expense, user: user, name: "Viagem")
      other_wallet_category = create(:category, :expense, user: user, name: "Outro bolso")

      create(:transaction, user: user, wallet: first_wallet, category: current_month_category, date: Date.new(2026, 4, 4), amount: 125.40, description: "Compra do mes")
      create(:transaction, user: user, wallet: first_wallet, category: previous_month_category, date: Date.new(2026, 3, 20), amount: 300.00, description: "Compra anterior")
      create(:transaction, user: user, wallet: second_wallet, category: other_wallet_category, date: Date.new(2026, 4, 5), amount: 450.00, description: "Outra carteira")

      get metrics_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Carteira principal")
      expect(response.body).to include("Mercado")
      expect(response.body).not_to include("Viagem")
      expect(response.body).not_to include("Outro bolso")
      expect(response.body).to include("Este mes")
      expect(response.body).to include("01/04/2026 ate 30/04/2026")
      expect(response.body).to include("R$ 125,40")
    end

    it "filters metrics by week using the provided reference date" do
      wallet = create(:wallet, user: user, name: "Operacional")
      week_category = create(:category, :expense, user: user, name: "Alimentacao")
      month_category = create(:category, :expense, user: user, name: "Transporte")

      create(:transaction, user: user, wallet: wallet, category: week_category, date: Date.new(2026, 4, 7), amount: 85.0, status: "paid")
      create(:transaction, user: user, wallet: wallet, category: month_category, date: Date.new(2026, 4, 2), amount: 210.0, status: "pending")
      create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", date: Date.new(2026, 4, 8), amount: 1000.0, status: "received")

      get metrics_path, params: {
        wallet_id: wallet.id,
        period: "week",
        reference_date: "2026-04-08"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Esta semana")
      expect(response.body).to include("Alimentacao")
      expect(response.body).not_to include("Transporte")
      expect(response.body).to include("Pago")
      expect(response.body).to include("Receita")
      expect(response.body).to include("06/04/2026 ate 12/04/2026")
    end

    it "renders the financial notification dropdown when expenses reach the warning threshold" do
      wallet = create(:wallet, user: user, name: "Casa")

      create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", status: "received", date: Date.new(2026, 4, 3), amount: 1000.0)
      create(:transaction, user: user, wallet: wallet, category: expense_category, status: "paid", date: Date.new(2026, 4, 4), amount: 500.0)

      get metrics_path, params: {
        wallet_id: wallet.id,
        period: "month",
        reference_date: "2026-04-08"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Volume financeiro por tipo")
      expect(response.body).to include("Despesas em ritmo de atencao")
      expect(response.body).to include("R$ 500,00 em despesas para R$ 1.000,00 em receitas.")
    end
  end
end
