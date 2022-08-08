# frozen_string_literal: true

require "spec_helper"

RSpec.describe Polyn::Cli::Naming do
  describe "#validate_stream_name!" do
    it "allows underscore separator" do
      expect { described_class.validate_stream_name!("foo_bar") }.to_not raise_error
    end

    it "allows lowercase" do
      expect { described_class.validate_stream_name!("foo") }.to_not raise_error
    end

    it "allows uppercase" do
      expect { described_class.validate_stream_name!("FOO") }.to_not raise_error
    end

    it "allows numbers" do
      expect { described_class.validate_stream_name!("FOO1") }.to_not raise_error
    end

    it "raises if spaces" do
      expect { described_class.validate_stream_name!("foo bar") }.to raise_error(Polyn::Cli::Error)
    end

    it "raises if non underscore special char" do
      expect { described_class.validate_stream_name!("foo-bar") }.to raise_error(Polyn::Cli::Error)
    end
  end
end
