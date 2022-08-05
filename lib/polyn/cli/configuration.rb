# frozen_string_literal: true

module Polyn
  class Cli
    ##
    # Configuration data for Polyn::Cli
    class Configuration
      attr_reader :polyn_env, :nats_servers

      def initialize
        @polyn_env    = ENV["POLYN_ENV"] || "development"
        @nats_servers = ENV["NATS_SERVERS"] || "localhost:4222"
      end
    end
  end
end
