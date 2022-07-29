class Gen < Thor
  namespace :gen
  desc "stream", "Generates a new stream configuration with boilerplate"
  def stream
    say "Creating new stream"
  end
end