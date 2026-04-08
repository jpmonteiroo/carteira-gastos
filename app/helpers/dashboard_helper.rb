module DashboardHelper
  def variation_percentage(current_value, previous_value)
    return 0 if previous_value.to_f.zero?

    (((current_value - previous_value) / previous_value) * 100).round(2)
  end
end
