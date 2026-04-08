require "rails_helper"
require "nokogiri"

RSpec.describe "Transactions", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, user: user) }
  let!(:expense_category) { create(:category, :expense, user: user, name: "Moradia") }
  let!(:income_category) { create(:category, :income, user: user, name: "Salario") }

  def parsed_document
    Nokogiri::HTML(response.body)
  end

  def column_values(column_index, selector = nil)
    parsed_document.css("table tbody tr").map do |row|
      cell = row.css("td")[column_index]
      target = selector.present? ? cell.at_css(selector) : cell
      target.text.gsub(/\s+/, " ").strip
    end
  end

  describe "authentication" do
    it "redirects unauthenticated users from index" do
      get wallet_transactions_path(wallet)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /wallets/:wallet_id/transactions" do
    before { sign_in user }

    around do |example|
      travel_to(Date.new(2026, 4, 8)) { example.run }
    end

    it "filters transactions by the current week" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 4, 7), description: "Semana atual")
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 4, 2), description: "Mes atual")

      get wallet_transactions_path(wallet), params: { period: "week" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Semana atual")
      expect(response.body).not_to include("Mes atual")
      expect(response.body).to include("Periodo: Esta semana")
    end

    it "filters transactions by the current month" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 4, 2), description: "Mes atual")
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 3, 12), description: "Trimestre atual")

      get wallet_transactions_path(wallet), params: { period: "month" }

      expect(response.body).to include("Mes atual")
      expect(response.body).not_to include("Trimestre atual")
    end

    it "filters transactions by the current quarter" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 5, 15), description: "Trimestre atual")
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 1, 20), description: "Semestre atual")

      get wallet_transactions_path(wallet), params: { period: "quarter" }

      expect(response.body).to include("Trimestre atual")
      expect(response.body).not_to include("Semestre atual")
    end

    it "filters transactions by the current semester" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 1, 20), description: "Semestre atual")
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 8, 15), description: "Ano atual")

      get wallet_transactions_path(wallet), params: { period: "semester" }

      expect(response.body).to include("Semestre atual")
      expect(response.body).not_to include("Ano atual")
    end

    it "filters transactions by the current year" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 8, 15), description: "Ano atual")
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2025, 12, 31), description: "Ano anterior")

      get wallet_transactions_path(wallet), params: { period: "year" }

      expect(response.body).to include("Ano atual")
      expect(response.body).not_to include("Ano anterior")
    end

    it "filters transactions by category" do
      alimentacao = create(:category, :expense, user: user, name: "Alimentacao")
      create(:transaction, user: user, wallet: wallet, category: expense_category, description: "Aluguel")
      create(:transaction, user: user, wallet: wallet, category: alimentacao, description: "Mercado")

      get wallet_transactions_path(wallet), params: { category_id: alimentacao.id }

      expect(response.body).to include("Mercado")
      expect(response.body).not_to include("Aluguel")
      expect(response.body).to include("Categoria: Alimentacao")
    end

    it "filters transactions by description" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, description: "Compra do mercado")
      create(:transaction, user: user, wallet: wallet, category: expense_category, description: "Pagamento da escola")

      get wallet_transactions_path(wallet), params: { description: "merc" }

      expect(response.body).to include("Compra do mercado")
      expect(response.body).not_to include("Pagamento da escola")
      expect(response.body).to include("Descricao: merc")
    end

    it "filters transactions by status" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, status: "pending", description: "Conta aguardando")
      create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", status: "received", description: "Salario recebido")

      get wallet_transactions_path(wallet), params: { status: "received" }

      expect(response.body).to include("Salario recebido")
      expect(response.body).not_to include("Conta aguardando")
      expect(response.body).to include("Status: Recebido")
    end

    it "sorts transactions by category" do
      bonus = create(:category, :income, user: user, name: "Bonus")
      alimentacao = create(:category, :expense, user: user, name: "Alimentacao")

      create(:transaction, user: user, wallet: wallet, category: expense_category, description: "Conta da casa")
      create(:transaction, user: user, wallet: wallet, category: alimentacao, description: "Mercado")
      create(:transaction, user: user, wallet: wallet, category: bonus, transaction_type: "income", description: "Premio")

      get wallet_transactions_path(wallet), params: { sort: "category", direction: "asc" }

      expect(column_values(0, "p")).to eq(["Alimentacao", "Bonus", "Moradia"])
    end

    it "sorts transactions by description" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, description: "Beta")
      create(:transaction, user: user, wallet: wallet, category: expense_category, description: "Alpha")
      create(:transaction, user: user, wallet: wallet, category: expense_category, description: "Gamma")

      get wallet_transactions_path(wallet), params: { sort: "description", direction: "asc" }

      expect(column_values(1, "p")).to eq(["Alpha", "Beta", "Gamma"])
    end

    it "sorts transactions by date" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 4, 6), description: "Beta")
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 4, 5), description: "Alpha")
      create(:transaction, user: user, wallet: wallet, category: expense_category, date: Date.new(2026, 4, 7), description: "Gamma")

      get wallet_transactions_path(wallet), params: { sort: "date", direction: "asc" }

      expect(column_values(2)).to eq(["05/04/2026", "06/04/2026", "07/04/2026"])
    end

    it "sorts transactions by status" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, status: "pending", description: "Pendente")
      create(:transaction, user: user, wallet: wallet, category: expense_category, status: "canceled", description: "Cancelado")
      create(:transaction, user: user, wallet: wallet, category: expense_category, status: "paid", description: "Pago")
      create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", status: "received", description: "Recebido")

      get wallet_transactions_path(wallet), params: { sort: "status", direction: "asc" }

      expect(column_values(3, "span")).to eq(["Cancelado", "Pago", "Pendente", "Recebido"])
    end

    it "sorts transactions by amount" do
      create(:transaction, user: user, wallet: wallet, category: expense_category, amount: 30, description: "Maior")
      create(:transaction, user: user, wallet: wallet, category: expense_category, amount: 10, description: "Menor")
      create(:transaction, user: user, wallet: wallet, category: expense_category, amount: 20, description: "Intermediario")

      get wallet_transactions_path(wallet), params: { sort: "amount", direction: "asc" }

      expect(column_values(4)).to eq(["-R$ 10,00", "-R$ 20,00", "-R$ 30,00"])
    end
  end

  describe "GET /wallets/:wallet_id/transactions/new" do
    before { sign_in user }

    it "renders the form with categories filtered by requested transaction type" do
      get new_wallet_transaction_path(wallet, transaction_type: "income")

      expect(response).to have_http_status(:ok)

      category_options = Nokogiri::HTML(response.body)
        .css("select#transaction_category_id option")
        .map(&:text)

      expect(category_options).to include("Selecione uma categoria", "Salario")
      expect(category_options).not_to include("Moradia")
    end
  end

  describe "POST /wallets/:wallet_id/transactions" do
    before { sign_in user }

    let(:valid_params) do
      {
        transaction: {
          category_id: expense_category.id,
          date: Date.current,
          amount: 150.75,
          transaction_type: "expense",
          status: "pending",
          description: "Aluguel"
        }
      }
    end

    it "creates a transaction and redirects to the wallet transaction list" do
      expect do
        post wallet_transactions_path(wallet), params: valid_params
      end.to change(Transaction, :count).by(1)

      expect(response).to redirect_to(wallet_transactions_path(wallet))
      expect(Transaction.last.user).to eq(user)
    end

    it "re-renders the form when category kind does not match transaction type" do
      invalid_params = valid_params.deep_dup
      invalid_params[:transaction][:transaction_type] = "income"

      expect do
        post wallet_transactions_path(wallet), params: invalid_params
      end.not_to change(Transaction, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("mesmo tipo")
    end
  end

  describe "GET /wallets/:wallet_id/transactions/:id/edit" do
    before { sign_in user }

    it "renders the form with categories filtered by the transaction kind" do
      transaction = create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income")

      get edit_wallet_transaction_path(wallet, transaction)

      expect(response).to have_http_status(:ok)

      category_options = Nokogiri::HTML(response.body)
        .css("select#transaction_category_id option")
        .map(&:text)

      expect(category_options).not_to include("Moradia")
    end
  end

  describe "PATCH /wallets/:wallet_id/transactions/:id" do
    before { sign_in user }

    it "updates the transaction and redirects to the show page" do
      transaction = create(:transaction, user: user, wallet: wallet, category: expense_category, transaction_type: "expense")

      patch wallet_transaction_path(wallet, transaction), params: {
        transaction: {
          category_id: income_category.id,
          transaction_type: "income",
          status: "received",
          description: "Recebimento atualizado"
        }
      }

      expect(response).to redirect_to(wallet_transaction_path(wallet, transaction))

      transaction.reload
      expect(transaction.category).to eq(income_category)
      expect(transaction.transaction_type).to eq("income")
      expect(transaction.status).to eq("received")
      expect(transaction.description).to eq("Recebimento atualizado")
    end
  end

  describe "DELETE /wallets/:wallet_id/transactions/:id" do
    before { sign_in user }

    it "deletes the transaction and redirects to the index page" do
      transaction = create(:transaction, user: user, wallet: wallet, category: expense_category, transaction_type: "expense")

      expect do
        delete wallet_transaction_path(wallet, transaction)
      end.to change(Transaction, :count).by(-1)

      expect(response).to redirect_to(wallet_transactions_path(wallet))
    end
  end
end
