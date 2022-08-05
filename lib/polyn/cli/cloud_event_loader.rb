# frozen_string_literal: true

module Polyn
  class Cli
    ##
    # Loads the JSON schmea into the event registry.
    class CloudEventLoader
      STORE_NAME = "POLYN_SCHEMAS"

      CLOUD_EVENT_SCHEMA = {
        "$schema"    => "http://json-schema.org/draft-04/schema#",
        "$id"        => "https://raw.githubusercontent.com/cloudevents/spec/v1.0.1/spec.json",
        "properties" => {
          "polyndata"  => {
            "type"       => "object",
            "properties" => {
              "lang"        => {
                "type" => "string",
              },
              "langversion" => {
                "type" => "string",
              },
              "version"     => {
                "type" => "string",
              },
            },
            "required"   => %w[lang langversion version],
          },
          "polyntrace" => {
            "type"  => "array",
            "items" => {
              "type"       => "object",
              "properties" => {
                "type" => {
                  "type" => "string",
                },
                "time" => {
                  "type" => "date-time",
                },
                "id"   => {
                  "type" => "uuid",
                },
              },
              "required"   => %w[type time id],
            },
          },
        },
        "required"   => %w[id type source specversion datacontenttype type data],
      }.freeze

      ##
      # Loads the events from the event repository into the Polyn event registry.
      # @return [Bool]
      def self.load(cli)
        new(cli).load_events
      end

      def initialize(thor)
        @thor   = thor
        @client = NATS.connect(Polyn::Cli.configuration.nats_servers).jetstream
        @bucket = client.key_value(STORE_NAME)

        @events = {}
      end

      # @private
      def load_events
        thor.say "Loading events into the Polyn event registry from '#{events_dir}'"
        read_events

        events.each do |name, event|
          bucket.put(name, event)
        end

        true
      end

      private

      def read_events
        Dir.glob(File.join(events_dir, "*.json")).each do |event_file|
          thor.say "Loading 'event #{event_file}'"
          event = wrap_cloud_event(JSON.parse(File.read(event_file)))

          events[event[File.basename(event_file, ".json")]] = event
        end
      end

      attr_reader :thor, :events, :client, :bucket

      def events_dir
        File.join(Dir.pwd, "events")
      end

      def wrap_cloud_event(event)
        CLOUD_EVENT_SCHEMA.merge(
          "properties" => CLOUD_EVENT_SCHEMA["properties"].merge(
            "data" => event,
          ),
        )
      end
    end
  end
end
