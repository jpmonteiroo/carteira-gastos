module ApplicationHelper
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
end
