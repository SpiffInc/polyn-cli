# frozen_string_literal: true

require "thor"
require "dotenv"
require "polyn/cli/configuration"
require "polyn/cli/stream_generator"
require "polyn/cli/cloud_event"
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

    class Error < StandardError; end

    ##
    # Configuration information for Polyn
    def self.configuration
      @configuration ||= Polyn::Cli::Configuration.new
    end

    ##
    # Thor commands for the CLI. Subclassed so other classes can be in the CLI namespace
    class Commands < Thor
      include Thor::Actions

      source_root File.join(__dir__, "templates")

      # https://github.com/rails/thor/wiki/Making-An-Executable
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
        Polyn::Cli::CloudEventLoader.new(self).load_events
      end

      private

      def polyn_env
        Polyn::Cli.configuration.polyn_env
      end

      def nats_servers
        Polyn::Cli.configuration.nats_servers
      end

      def tf_apply
        if polyn_env == "development"
          %(terraform apply -var "jetstream_servers=#{nats_servers}" -auto-approve)
        else
          %(terraform apply -var "jetstream_servers=#{nats_servers}")
        end
      end

      register(Polyn::Cli::StreamGenerator, "gen:stream", "gen:stream NAME",
        "Generates a new stream configuration with boilerplate")
    end
  end
end
