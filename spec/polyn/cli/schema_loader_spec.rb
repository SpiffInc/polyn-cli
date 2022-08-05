# frozen_string_literal: true

require "spec_helper"

class FakeThor < Thor
end

RSpec.describe Polyn::Cli::SchemaLoader do
  describe "#load_events" do
    include_context :tmp_dir

    let(:store_name) { "SCHEMA_LOADER_TEST_STORE" }
    let(:thor) { double("thor") }
    let(:nats) { NATS.connect }
    let(:js) { nats.jetstream }

    before(:each) do
      allow(thor).to receive(:say)
      js.create_key_value(bucket: store_name)
    end

    after(:each) do
      js.delete_key_value(store_name)
    end

    subject do
      described_class.new(thor,
        store_name: store_name,
        events_dir: tmp_dir)
    end

    it "it loads events to the store" do
      add_schema_file("app.widgets.v1", {
        "type"       => "object",
        "properties" => {
          "name" => { "type" => "string" },
        },
      })

      subject.load_events

      schema  = get_schema("app.widgets.v1")
      datadef = schema["definitions"]["datadef"]
      expect(datadef).to eq({
        "type"       => "object",
        "properties" => {
          "name" => { "type" => "string" },
        },
      })
    end

    it "invalid json schema document raises" do
      add_schema_file("app.widgets.v1", "foo")

      expect { subject.load_events }.to raise_error(Polyn::Cli::ValidationError)
    end

    it "non-json documents are ignored" do
      path = File.join(tmp_dir, "foo.png")
      File.write(path, "foo")
      expect { subject.load_events }.to_not raise_error
    end

    def add_schema_file(name, content)
      path = File.join(tmp_dir, "#{name}.json")
      File.write(path, JSON.generate(content))
    end

    def get_schema(name)
      kv    = js.key_value(store_name)
      entry = kv.get(name)
      JSON.parse(entry.value)
    end
  end
end
