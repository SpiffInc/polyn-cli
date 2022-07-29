# frozen_string_literal: true

require "thor"
require "dotenv"
require_relative "./gen"

Dotenv.load

module Polyn
  class Cli < Thor
    include Thor::Actions
    class Error < StandardError; end

    VERSION      = "0.1.0"

    source_root File.join(__dir__, "templates")

    desc "gen", "Polyn generators"
    subcommand "gen", Gen

    desc "init", "initializes a Polyn event repository"
    def init
      say "Initializing Polyn event repository"
      template "Gemfile", "Gemfile"
      directory "tf", "tf"
      directory "events", "events"
      template "docker-compose.yml", "docker-compose.yml"
      template "gitignore", ".gitignore"
      template "README.md", "README.md"
      say "Iniitalizing Terraform"
      inside "tf" do
        run "tf init"
      end
      say "Running bundler"
      run "bundle install"
      say "Initializing git"
      run "git init"
      say "Repository initialized"
    end

    desc "setup", "sets up a Polyn event repository on a developer machine"
    def setup
      say "Setting up the events repository"
      say "Running bundler"
      run "bundle install"
      run "Initializing Terraform"
      inside "tf" do
        run "tf init"
      end
      say("Repository set up")
    end

    desc "up", "updates the JetStream streams and consumers, as well the Polyn event registry"
    def up
      say "Updating JetStream configuration"
      inside "tf" do
        run tf_apply
      end
      say "Updating Polyn event registry"
      CloudEventLoader.new(polyn_env, self).load_events
    end

    private

    def polyn_env
      ENV["POLYN_ENV"] || "development"
    end

    def tf_apply
      if polyn_env == "development"
        'tf apply -var "jetstream_servers=localhost:4222" -auto-approve'
      else
        %(tf apply -var "jestream_servers=#{ENV['JETSTREAM_SERVERS']}")
      end
    end
  end
end

require_relative "cli/cloud_event_loader"
