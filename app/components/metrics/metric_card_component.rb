module Metrics
  class MetricCardComponent < ApplicationComponent
    TONE_CLASSES = {
      slate: "text-slate-500",
      emerald: "text-emerald-600",
      rose: "text-rose-600",
      amber: "text-amber-600",
      teal: "text-teal-600"
    }.freeze

    def initialize(title:, value:, subtitle:, tone: :slate)
      @title = title
      @value = value
      @subtitle = subtitle
      @tone = tone
    end

    private

    attr_reader :title, :value, :subtitle, :tone

    def subtitle_classes
      TONE_CLASSES.fetch(tone, TONE_CLASSES[:slate])
    end
  end
end
