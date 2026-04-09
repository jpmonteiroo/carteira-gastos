module Metrics
  class HorizontalBarChartComponent < ApplicationComponent
    def initialize(title:, subtitle:, items:, empty_message:, action_label: nil, action_path: nil)
      @title = title
      @subtitle = subtitle
      @items = items
      @empty_message = empty_message
      @action_label = action_label
      @action_path = action_path
    end

    private

    attr_reader :title, :subtitle, :items, :empty_message, :action_label, :action_path

    def max_value
      @max_value ||= items.map { |item| item[:value].to_d }.max.to_d
    end

    def bar_width(value)
      return 0 if max_value.zero?

      ((value.to_d / max_value) * 100).round(1)
    end

    def bar_classes(item)
      tone = item[:tone] || :teal

      case tone
      when :emerald
        "bg-emerald-500/85"
      when :rose
        "bg-rose-500/80"
      when :amber
        "bg-amber-500/85"
      when :slate
        "bg-slate-500/85"
      else
        "bg-teal-500/85"
      end
    end
  end
end
