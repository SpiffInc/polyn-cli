# Polyn Events Repository

This repository contains all of the events and terraform resources for the Polyn services
environment.

## Development Setup

1. Install [Ruby]()
2. Install Terraform. For M1 Macs, [download the AMD64 version](https://www.terraform.io/downloads)
   rather than using Homebrew to install Terraform.
3. Ensure Docker & Docker Compose is installed
4. [Install the Polyn CLI]()
5. Call `polyn up`. By default this will run in `development` mode, which will start the NATS
   server, configure it via Terraform, and update the Polyn Event Registry.

## Streams

Each stream should have its own configuration file under `./tf`. Run `polyn gen:stream <stream_name>` to generate a new configuration file for a stream