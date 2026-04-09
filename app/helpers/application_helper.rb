module ApplicationHelper
  TIME_PERIOD_LABELS = {
    "week" => "Esta semana",
    "month" => "Este mes",
    "quarter" => "Este trimestre",
    "semester" => "Este semestre",
    "year" => "Este ano"
  }.freeze

  def brl(amount)
    number_to_currency(amount || 0, unit: "R$ ", separator: ",", delimiter: ".", precision: 2)
  end

  def display_date(date)
    return "-" unless date

    I18n.l(date, format: "%d/%m/%Y")
  end

  def nav_link_classes(path, match: :exact)
    base = "inline-flex items-center rounded-full px-4 py-2 text-sm font-semibold transition duration-200"
    active = match == :prefix ? request.path.start_with?(path) : current_page?(path)

    if active
      "#{base} bg-slate-950 text-white shadow-lg shadow-slate-900/15"
    else
      "#{base} text-slate-600 hover:bg-white/70 hover:text-slate-950"
    end
  end

  def time_period_label(period)
    TIME_PERIOD_LABELS[period] || period.to_s.humanize
  end

  def time_period_options(periods)
    periods.map { |period| [time_period_label(period), period] }
  end

  def category_kind_label(kind)
    {
      "income" => "Receita",
      "expense" => "Despesa"
    }[kind] || kind.to_s.humanize
  end

  def transaction_type_label(kind)
    category_kind_label(kind)
  end

  def transaction_status_label(status)
    {
      "pending" => "Pendente",
      "paid" => "Pago",
      "received" => "Recebido",
      "canceled" => "Cancelado"
    }[status] || status.to_s.humanize
  end

  def badge_classes(tone = :slate)
    base = "inline-flex items-center rounded-full border px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.2em]"

    palette = case tone
              when :emerald
                "border-emerald-200 bg-emerald-50 text-emerald-700"
              when :rose
                "border-rose-200 bg-rose-50 text-rose-700"
              when :amber
                "border-amber-200 bg-amber-50 text-amber-700"
              when :teal
                "border-teal-200 bg-teal-50 text-teal-700"
              else
                "border-slate-200 bg-slate-50 text-slate-700"
              end

    "#{base} #{palette}"
  end

  def category_badge_classes(kind)
    kind == "income" ? badge_classes(:emerald) : badge_classes(:rose)
  end

  def status_badge_classes(status)
    case status
    when "paid"
      badge_classes(:emerald)
    when "received"
      badge_classes(:teal)
    when "pending"
      badge_classes(:amber)
    when "canceled"
      badge_classes(:slate)
    else
      badge_classes(:teal)
    end
  end

  def amount_text_classes(transaction_type)
    transaction_type == "income" ? "text-emerald-700" : "text-rose-700"
  end

  def signed_brl(amount, transaction_type)
    signal = transaction_type == "income" ? "+" : "-"
    "#{signal}#{brl(amount)}"
  end

  def financial_notifications_context
    @financial_notifications_context || {
      wallet: nil,
      period: Notifications::FinancialVolumeQuery::DEFAULT_PERIOD,
      reference_date: Date.current,
      date_range: Date.current.beginning_of_month..Date.current.end_of_month,
      notifications: []
    }
  end

  def financial_notifications
    financial_notifications_context[:notifications] || []
  end

  def highest_notification_tone(notifications)
    return :slate if notifications.blank?

    notifications.any? { |notification| notification[:tone] == :rose } ? :rose : :amber
  end

  def financial_notification_button_classes(tone)
    base = "inline-flex items-center gap-3 rounded-[24px] border px-3 py-2 transition duration-200"

    palette = case tone
              when :rose
                "border-rose-200 bg-rose-50/80 text-rose-700 hover:bg-rose-100"
              when :amber
                "border-amber-200 bg-amber-50/80 text-amber-700 hover:bg-amber-100"
              else
                "border-white/70 bg-white/70 text-slate-500 hover:bg-white"
              end

    "#{base} #{palette}"
  end

  def financial_notification_counter_classes(tone)
    base = "absolute -right-1 -top-1 inline-flex h-4.5 min-w-4.5 items-center justify-center rounded-full px-1 text-[9px] font-bold leading-none text-white"

    palette = tone == :rose ? "bg-rose-600" : "bg-amber-500"

    "#{base} #{palette}"
  end

  def financial_notification_icon_wrapper_classes(tone)
    base = "flex h-11 w-11 items-center justify-center rounded-2xl text-sm"

    palette = case tone
              when :rose
                "bg-rose-100 text-rose-600"
              when :amber
                "bg-amber-100 text-amber-600"
              else
                "bg-slate-100 text-slate-500"
              end

    "#{base} #{palette}"
  end

  def financial_notifications_metrics_path
    context = financial_notifications_context
    wallet = context[:wallet]
    return metrics_path unless wallet.present?

    metrics_path(
      wallet_id: wallet.id,
      period: context[:period],
      reference_date: context[:reference_date]
    )
  end

  def financial_notifications_summary_label(count)
    return "Sem alertas" if count.zero?
    return "1 notificacao" if count == 1

    "#{count} notificacoes"
  end
end
