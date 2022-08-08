# frozen_string_literal: true

module Polyn
  class Cli
    ##
    # Generates a new JSON Schema file for an event
    class SchemaGenerator < Thor::Group
      include Thor::Actions

      desc "Generates a new JSON Schema file for an event"

      argument :event_type, required: true
      class_option :dir, default: Dir.getwd

      source_root File.join(File.expand_path(__dir__), "../templates")

      def check_name
        Polyn::Cli::Naming.validate_event_type!(event_type)
      end

      def file_name
        @file_name ||= "#{event_type}.json"
      end

      def schema_id
        Polyn::Cli::Naming.dot_to_colon(event_type)
      end

      def create
        say "Creating new schema for #{event_type}"
        template "generators/schema.json", File.join(options.dir, "events/#{event_type}.json")
      end
    end
  end
end
