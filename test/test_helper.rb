ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest"
require "rails/test_unit/runner"

if Gem::Version.new(Minitest::VERSION) >= Gem::Version.new("6.0.0") && defined?(Rails::LineFiltering)
  module Rails
    module LineFiltering
      # Rails 7.1 expects the older Minitest arity here. Minitest 6 passes an
      # extra argument, so we accept and forward it to keep `bin/rails test`
      # working in CI.
      def run(reporter, options = {}, *args)
        options = options.merge(filter: Rails::TestUnit::Runner.compose_filter(self, options[:filter]))
        super(reporter, options, *args)
      end
    end
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
