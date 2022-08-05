# frozen_string_literal: true

require "thor"
require "dotenv"
require "polyn/cli/stream_generator"
require "polyn/cli/cloud_event_loader"
require "polyn/cli/version"
require "json"
require "nats/client"

Dotenv.load

module Polyn
  ##
  # CLI for Polyn for configuring NATS server
  class Cli
    ##
    # Proxy to Thor start
    def self.start(args)
      Commands.start(args)
    end

    ##
    # Thor commands for the CLI. Subclasses so other classes can be in the CLI namespace
    class Commands < Thor
      include Thor::Actions
      class Error < StandardError; end

      source_root File.join(__dir__, "templates")

      def self.exit_on_failure?
        true
      end

      desc "init", "initializes a Polyn event repository"
      def init
        say "Initializing Polyn event repository"
        directory "tf", "tf"
        directory "events", "events"
        template "gitignore", ".gitignore"
        template "README.md", "README.md"
        run tf_init
        say "Initializing git"
        run "git init"
        say "Repository initialized"
      end

      desc "tf_init", "Initializes Terraform for configuration"
      def tf_init
        say "Initializing Terraform"
        inside "tf" do
          run "terraform init"
        end
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
          'terraform apply -var "jetstream_servers=localhost:4222" -auto-approve'
        else
          %(terraform apply -var "jetstream_servers=#{ENV['JETSTREAM_SERVERS']}")
        end
      end

      register(Polyn::StreamGenerator, "gen:stream", "gen:stream NAME",
        "Generates a new stream configuration with boilerplate")
    end
  end
end
