# frozen_string_literal: true

require "spec_helper"

RSpec.describe Polyn::Cli do
  subject do
    Polyn::Cli::Commands.new
  end

  it "has a version number" do
    expect(Polyn::Cli::VERSION).not_to be nil
  end

  describe "#init" do
    include_context :tmp_dir
    it "creates a new codebase" do
      subject.invoke(:init, [], { dir: tmp_dir })
      expect(File.exist?(File.join(tmp_dir, "tf/event_registry.tf"))).to be true
      expect(File.exist?(File.join(tmp_dir, "tf/main.tf"))).to be true
      expect(File.exist?(File.join(tmp_dir, "tf/widgets.tf"))).to be true
      expect(File.exist?(File.join(tmp_dir, "events/widgets.created.v1.json"))).to be true
      expect(File.exist?(File.join(tmp_dir, "README.md"))).to be true
      expect(File.exist?(File.join(tmp_dir, ".gitignore"))).to be true
      expect(File.exist?(File.join(tmp_dir, "docker-compose.yml"))).to be true
    end
  end

  describe "#gen:stream" do
    include_context :tmp_dir
    it "it creates a new stream file" do
      subject.invoke("gen:stream", ["foo"], { dir: tmp_dir })
      path = File.join(tmp_dir, "events/foo.tf")
      expect(File.exist?(path)).to be true
      expect(File.read(path)).to include(%(resource "jetstream_stream" "FOO"))
    end
  end
end
