# frozen_string_literal: true

require "json"

module Polyn
  class Cli
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

      def initialize(env, thor)
        @env  = env
        @thor = thor

        @events = {}
      end

      def load
        thor.say "Loading events into the Polyn event registry from '#{events_dir}'"
        Dir.glob(File.join(events_dir, "*.json")).each do |event_file|
          thor.say "Loading 'event #{event_file}'"
          event = wrap_cloud_event(JSON.parse(File.read(event_file)))

          events[event[File.basename(event_file, ".json")]] = event
        end

        events.each do |name, event|
        end
      end

      private

      attr_reader :env, :thor, :events

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
