# frozen_string_literal: true

module Polyn
  class Cli
    ##
    # Loads the JSON schmea into the event registry.
    class SchemaLoader
      include Thor::Actions

      STORE_NAME = "POLYN_SCHEMAS"

      ##
      # Loads the events from the event repository into the Polyn event registry.
      # @return [Bool]
      def self.load(cli)
        new(cli).load_events
      end

      def initialize(thor, **opts)
        @thor               = thor
        @client             = NATS.connect(Polyn::Cli.configuration.nats_servers).jetstream
        @bucket             = client.key_value(opts.fetch(:store_name, STORE_NAME))
        @cloud_event_schema = Polyn::Cli::CloudEvent.to_h.freeze
        @events_dir         = opts.fetch(:events_dir, File.join(Dir.pwd, "events"))
        @events             = {}
      end

      def load_events
        thor.say "Loading events into the Polyn event registry from '#{events_dir}'"
        read_events

        events.each do |name, event|
          bucket.put(name, JSON.generate(event))
        end

        true
      end

      private

      attr_reader :thor, :events, :client, :bucket, :cloud_event_schema, :events_dir

      def read_events
        Dir.glob(File.join(events_dir, "*.json")).each do |event_file|
          thor.say "Loading 'event #{event_file}'"
          event = compose_cloud_event(JSON.parse(File.read(event_file)))

          events[File.basename(event_file, ".json")] = event
        end
      end

      def compose_cloud_event(event_schema)
        cloud_event_schema.merge({
          "definitions" => cloud_event_schema["definitions"].merge({
            "datadef" => event_schema,
          }),
        })
      end
    end
  end
end
