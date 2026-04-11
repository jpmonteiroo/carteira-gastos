class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wallet
  before_action :set_transaction, only: %i[show edit update destroy]

  def index
    @selected_period = params[:period].presence_in(::Constants::PERIODS)
    @selected_category_id = selected_category_id
    @selected_description = params[:description].to_s.strip
    @selected_status = params[:status].presence_in(Transaction::STATUSES)
    query = ::Transactions::IndexQuery.new(
      scope: @wallet.transactions,
      filters: {
        period: @selected_period,
        category_id: @selected_category_id,
        description: @selected_description,
        status: @selected_status
      },
      sort: params[:sort],
      direction: params[:direction]
    )

    @transactions = query.call
    @selected_sort = query.selected_sort
    @selected_direction = query.selected_direction
    @available_categories = current_user.categories.order(:name)
    @active_filters = build_active_filters
  end

  def show; end

  def new
    @transaction = build_transaction(default_transaction_attributes)
    load_form_collections
  end

  def create
    @transaction = build_transaction(transaction_params)

    if @transaction.save
      redirect_to wallet_transactions_path(@wallet), notice: "Lançamento criado com sucesso."
    else
      render_form(:new)
    end
  end

  def edit
    load_form_collections
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to wallet_transaction_path(@wallet, @transaction), notice: "Lançamento atualizado com sucesso."
    else
      render_form(:edit)
    end
  end

  def destroy
    @transaction.destroy
    redirect_to wallet_transactions_path(@wallet), notice: "Lançamento removido com sucesso."
  end

  private

  def set_wallet
    @wallet = current_user.wallets.find(params[:wallet_id])
  end

  def set_transaction
    @transaction = @wallet.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :category_id,
      :date,
      :amount,
      :transaction_type,
      :status,
      :description
    )
  end

  def build_transaction(attributes = {})
    @wallet.transactions.new(attributes).tap do |transaction|
      transaction.user = current_user
    end
  end

  def default_transaction_attributes
    {
      date: Date.current,
      transaction_type: default_transaction_type,
      status: "pending"
    }
  end

  def default_transaction_type
    params[:transaction_type].presence_in(Transaction::TYPES) || "expense"
  end

  def render_form(view)
    load_form_collections
    render view, status: :unprocessable_content
  end

  def load_form_collections
    @selected_transaction_kind = @transaction.transaction_type.presence_in(Transaction::TYPES)
    categories_query = Transactions::FormCategoriesQuery.new(
      user: current_user,
      transaction_type: @selected_transaction_kind
    )

    @categories = categories_query.filtered
    @all_categories_for_form = categories_query.serialized
    @submit_disabled = @categories.empty?
  end

  def build_active_filters
    [].tap do |filters|
      filters << "Periodo: #{view_context.transaction_period_label(@selected_period)}" if @selected_period.present?
      filters << "Categoria: #{selected_category.name}" if selected_category.present?
      filters << "Descricao: #{@selected_description}" if @selected_description.present?
      filters << "Status: #{view_context.transaction_status_label(@selected_status)}" if @selected_status.present?
    end
  end

  def selected_category_id
    category_id = params[:category_id].to_s.strip
    return if category_id.blank?

    category_id.to_i if current_user.categories.exists?(id: category_id)
  end

  def selected_category
    return unless @selected_category_id.present?

    @selected_category ||= current_user.categories.find_by(id: @selected_category_id)
  end
end
