# frozen_string_literal: true

module Polyn
  class Cli
    class Naming
      def self.validate_stream_name!(name)
        unless name.match(/^[a-zA-Z0-9_]+$/)
          raise Polyn::Cli::Error,
            "Stream name must be all alphanumeric, uppercase, and underscore separated. Got #{name}"
        end
      end

      def self.format_stream_name(name)
        name.upcase
      end

      def self.validate_source_name!(name)
        unless name.is_a?(String) && name.match?(/\A[a-z0-9]+(?:(?:\.|:)[a-z0-9]+)*\z/)
          raise Polyn::Cli::Error,
            "Event source must be lowercase, alphanumeric and dot/colon separated, got #{name}"
        end
      end
    end
  end
end
