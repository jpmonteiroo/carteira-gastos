require "rails_helper"

RSpec.describe "Wallets", type: :request do
  let(:user) { create(:user) }

  describe "authentication" do
    it "redirects unauthenticated users from index" do
      get wallets_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /wallets" do
    before { sign_in user }

    it "lists only the current user wallets" do
      own_wallet = create(:wallet, user: user, name: "Principal")
      other_wallet = create(:wallet, name: "Outro usuario")
      category = create(:category, :expense, user: user, name: "Moradia")
      create(:transaction, user: user, wallet: own_wallet, category: category, transaction_type: "expense")

      get wallets_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Principal")
      expect(response.body).not_to include(other_wallet.name)
      expect(response.body).to include("1 lanc.")
    end

    it "filters wallets by name" do
      create(:wallet, user: user, name: "Reserva de emergencia")
      create(:wallet, user: user, name: "Viagens")

      get wallets_path, params: { name: "Reserva" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reserva de emergencia")
      expect(response.body).to include("Nome: Reserva")
    end
  end

  describe "GET /wallets/:id" do
    before { sign_in user }

    it "shows wallet details and related transactions" do
      wallet = create(:wallet, user: user, name: "Reserva")
      category = create(:category, :income, user: user, name: "Salario")
      create(:transaction, user: user, wallet: wallet, category: category, transaction_type: "income", description: "Salario do mes")

      get wallet_path(wallet)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reserva")
      expect(response.body).to include("Salario")
    end
  end

  describe "POST /wallets" do
    before { sign_in user }

    it "creates a wallet and redirects to show" do
      expect do
        post wallets_path, params: {
          wallet: {
            name: "Viagens",
            description: "Planejamento anual"
          }
        }
      end.to change(Wallet, :count).by(1)

      wallet = Wallet.last
      expect(response).to redirect_to(wallet_path(wallet))
      expect(wallet.user).to eq(user)
    end

    it "re-renders the form when params are invalid" do
      expect do
        post wallets_path, params: {
          wallet: {
            name: "",
            description: "Sem nome"
          }
        }
      end.not_to change(Wallet, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Ajustes necessarios")
    end
  end

  describe "PATCH /wallets/:id" do
    before { sign_in user }

    it "updates the wallet and redirects to show" do
      wallet = create(:wallet, user: user, name: "Antiga")

      patch wallet_path(wallet), params: {
        wallet: {
          name: "Nova",
          description: "Descricao atualizada"
        }
      }

      expect(response).to redirect_to(wallet_path(wallet))

      wallet.reload
      expect(wallet.name).to eq("Nova")
      expect(wallet.description).to eq("Descricao atualizada")
    end

    it "re-renders edit when params are invalid" do
      wallet = create(:wallet, user: user)

      patch wallet_path(wallet), params: {
        wallet: {
          name: "",
          description: "Descricao"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Ajustes necessarios")
    end
  end

  describe "DELETE /wallets/:id" do
    before { sign_in user }

    it "deletes the wallet and redirects to index" do
      wallet = create(:wallet, user: user)

      expect do
        delete wallet_path(wallet)
      end.to change(Wallet, :count).by(-1)

      expect(response).to redirect_to(wallets_path)
    end
  end
end
