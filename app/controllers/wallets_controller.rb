class WalletsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wallet, only: %i[show edit update destroy]

  def index
    @selected_name = params[:name].to_s.strip
    @wallets = ::Wallets::IndexQuery.new(
      user: current_user,
      filters: { name: @selected_name }
    ).call
    @wallets_count = @wallets.size
    @active_filters = build_active_filters
  end

  def show
    load_wallet_details
  end

  def new
    @wallet = build_wallet
  end

  def create
    @wallet = build_wallet(wallet_params)

    if @wallet.save
      redirect_to @wallet, notice: "Carteira criada com sucesso."
    else
      render_form(:new)
    end
  end

  def edit; end

  def update
    if @wallet.update(wallet_params)
      redirect_to @wallet, notice: "Carteira atualizada com sucesso."
    else
      render_form(:edit)
    end
  end

  def destroy
    @wallet.destroy
    redirect_to wallets_path, notice: "Carteira removida com sucesso."
  end

  private

  def set_wallet
    @wallet = current_user.wallets.find(params[:id])
  end

  def wallet_params
    params.require(:wallet).permit(:name, :description)
  end

  def build_wallet(attributes = {})
    current_user.wallets.new(attributes)
  end

  def load_wallet_details
    @transactions = @wallet.transactions.includes(:category).order(date: :desc)
    @income_total = @transactions.incomes.sum(:amount)
    @expense_total = @transactions.expenses.sum(:amount)
    @balance = @income_total - @expense_total
  end

  def render_form(view)
    render view, status: :unprocessable_content
  end

  def build_active_filters
    [].tap do |filters|
      next unless @selected_name.present?

      filters << "Nome: #{@selected_name}"
    end
  end
end
