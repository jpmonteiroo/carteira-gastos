module TransactionsHelper
  def transaction_period_label(period)
    time_period_label(period)
  end

  def transaction_period_options
    time_period_options(::Transactions::IndexQuery::PERIODS)
  end

  def transaction_sort_link(wallet:, column:, label:, selected_sort:, selected_direction:)
    active = selected_sort == column
    next_direction = active && selected_direction == "asc" ? "desc" : "asc"
    query_params = request.query_parameters.symbolize_keys.merge(
      sort: column,
      direction: next_direction
    )

    link_to sort_label(label, active, selected_direction),
            wallet_transactions_path(wallet, query_params),
            class: sort_link_classes(active)
  end

  private

  def sort_label(label, active, selected_direction)
    return label unless active

    "#{label} (#{selected_direction == 'asc' ? 'Asc' : 'Desc'})"
  end

  def sort_link_classes(active)
    classes = %w[inline-flex items-center gap-2 text-sm font-semibold transition]
    classes << if active
                 "text-slate-950"
               else
                 "text-slate-500 hover:text-slate-950"
               end
    classes.join(" ")
  end
end
