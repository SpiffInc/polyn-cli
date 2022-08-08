# frozen_string_literal: true

module Polyn
  class Cli
    ##
    # Generates a new NATS Consumer configuration for a stream
    class ConsumerGenerator < Thor::Group
      include Thor::Actions

      desc "Generates a new NATS Consumer configuration for a stream"

      argument :stream_name, required: true
      argument :source_name, required: true
      argument :event_type, required: true
      class_option :dir, default: Dir.getwd

      source_root File.join(File.expand_path(__dir__), "../templates")

      def check_names
        Polyn::Cli::Naming.validate_stream_name!(stream_name)
        Polyn::Cli::Naming.validate_source_name!(source_name)
        Polyn::Cli::Naming.validate_event_type!(event_type)
      end

      def format_names
        @stream_name = stream_name.upcase
      end

      def consumer_name
        source = Polyn::Cli::Naming.colon_to_underscore(source_name)
        source = Polyn::Cli::Naming.dot_to_underscore(source)
        type   = Polyn::Cli::Naming.dot_to_underscore(event_type)
        "#{source}_#{type}"
      end

      def file_name
        @file_name ||= stream_name.downcase
      end

      def file_path
        File.join(options.dir, "tf", "#{file_name}.tf")
      end

      def create
        say "Creating new consumer config #{consumer_name} for stream #{stream_name}"
        consumer_config = <<~TF

          resource "jetstream_consumer" "#{consumer_name}" {
            stream_id = jetstream_stream.#{stream_name}.id
            durable_name = "#{consumer_name}"
            deliver_all = true
            filter_subject = "#{event_type}"
            sample_freq = 100
          }
        TF
        append_to_file(file_path, consumer_config)
      end
    end
  end
end
