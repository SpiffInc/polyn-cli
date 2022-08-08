# frozen_string_literal: true

require "spec_helper"

RSpec.describe Polyn::Cli do
  subject do
    Polyn::Cli::Commands.new
  end

  describe "commands" do
    include_context :tmp_dir

    it "has a version number" do
      expect(Polyn::Cli::VERSION).not_to be nil
    end

    it "creates a new codebase" do
      subject.invoke(:init, [], { dir: tmp_dir })
    end
  end
end
