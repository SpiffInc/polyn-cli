# frozen_string_literal: true

class Gen < Thor
  desc "stream", "Generates a new stream configuration with boilerplate"
  def stream(name)
    name = name.upcase
    unless name.match(/^[A-Z0-9_]+$/)
      raise Polyn::Cli::Error,
        "Stream name must be all alphanumeric, uppercase, and underscore separated. Got #{name}"
    end

    say "Creating new stream #{name}"
  end
end
