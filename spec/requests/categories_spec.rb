require "rails_helper"

RSpec.describe "Categories", type: :request do
  let(:user) { create(:user) }

  describe "authentication" do
    it "redirects unauthenticated users from index" do
      get categories_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /categories" do
    before { sign_in user }

    it "lists only the current user categories" do
      own_category = create(:category, :income, user: user, name: "Salario")
      other_category = create(:category, :expense, name: "Outro usuario")
      create(:transaction, user: user, category: own_category, transaction_type: "income")

      get categories_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Salario")
      expect(response.body).not_to include(other_category.name)
      expect(response.body).to include("1 lanc.")
    end

    it "filters categories by kind" do
      create(:category, :income, user: user, name: "Salario")
      create(:category, :expense, user: user, name: "Moradia")

      get categories_path, params: { kind: "income" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Salario")
      expect(response.body).not_to include("Moradia")
      expect(response.body).to include("Tipo: Receita")
    end
  end

  describe "POST /categories" do
    before { sign_in user }

    it "creates a category and redirects to index" do
      expect do
        post categories_path, params: {
          category: {
            name: "Investimentos",
            kind: "income",
            color: "#22c55e"
          }
        }
      end.to change(Category, :count).by(1)

      expect(response).to redirect_to(categories_path)
      expect(Category.last.user).to eq(user)
    end

    it "re-renders the form when params are invalid" do
      expect do
        post categories_path, params: {
          category: {
            name: "",
            kind: "income",
            color: "#22c55e"
          }
        }
      end.not_to change(Category, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Ajustes necessarios")
    end
  end

  describe "PATCH /categories/:id" do
    before { sign_in user }

    it "updates the category and redirects to index" do
      category = create(:category, :expense, user: user, name: "Moradia")

      patch category_path(category), params: {
        category: {
          name: "Casa",
          kind: "expense",
          color: "#ef4444"
        }
      }

      expect(response).to redirect_to(categories_path)

      category.reload
      expect(category.name).to eq("Casa")
      expect(category.color).to eq("#ef4444")
    end

    it "re-renders edit when params are invalid" do
      category = create(:category, :expense, user: user)

      patch category_path(category), params: {
        category: {
          name: "",
          kind: "expense"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Ajustes necessarios")
    end
  end

  describe "DELETE /categories/:id" do
    before { sign_in user }

    it "deletes the category and redirects to index" do
      category = create(:category, :expense, user: user)

      expect do
        delete category_path(category)
      end.to change(Category, :count).by(-1)

      expect(response).to redirect_to(categories_path)
    end
  end
end
