module Metrics
  class VerticalBarChartComponent < ApplicationComponent
    def initialize(title:, subtitle:, items:, empty_message:)
      @title = title
      @subtitle = subtitle
      @items = items
      @empty_message = empty_message
    end

    private

    attr_reader :title, :subtitle, :items, :empty_message

    def max_value
      @max_value ||= items.map { |item| item[:value].to_d }.max.to_d
    end

    def column_height(value)
      return 0 if max_value.zero?

      ((value.to_d / max_value) * 100).round(1)
    end
  end
end
