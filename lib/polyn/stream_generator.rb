# frozen_string_literal: true

module Polyn
  class StreamGenerator < Thor::Group
    include Thor::Actions

    desc "Generates a new stream configuration with boilerplate"

    argument :name, required: true

    source_root File.join(__dir__, "templates")

    def check_name
      unless name.match(/^[a-zA_Z0-9_]+$/)
        raise Polyn::Cli::Error,
          "Stream name must be all alphanumeric, uppercase, and underscore separated. Got #{name}"
      end
    end

    def file_name
      @file_name ||= name.downcase
    end

    def stream_name
      @stream_name ||= name.upcase
    end

    def create
      say "Creating new stream #{stream_name}"
      template "generators/stream.tf", "events/#{file_name}.tf"
    end
  end
end