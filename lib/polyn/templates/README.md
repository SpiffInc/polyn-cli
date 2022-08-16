# Polyn Events Repository

This repository contains all of the events and terraform resources for the Polyn services
environment.

## Development Setup

1. Install [Ruby](https://github.com/asdf-vm/asdf-ruby)
2. Install Terraform. For M1 Macs, [download the AMD64 version](https://www.terraform.io/downloads)
   rather than using Homebrew to install Terraform.
3. Ensure Docker & Docker Compose is installed
4. [Install the Polyn CLI]()
5. Call `polyn tf_init` if this is the first time using terraform in the codebase.
6. Call `polyn up`. By default this will run in `development` mode, which will start the NATS
   server, configure it via Terraform, and update the Polyn Event Registry.

## Streams

Each stream should have its own configuration file under `./tf` . Run `polyn gen:stream <stream_name>` to generate a new configuration file for a stream

## Consumers

Run `polyn gen:consumer <stream_name> <destination_name> <event_type>` to generate new configuration for a consumer of a stream. It will be included in the same file as the stream configuration.

## Event Schemas

Run `polyn gen:schema <event_type>` to generate a new JSON Schema for an event

All the schemas for your events should live in the `./events` directory.
The name of your schema file should be the same as your event, but with `.json` at the end.
So if you have an event called `widgets.created.v1` you would create a schema file called `widgets.created.v1.json` in the `./events` directory.
Every schema should be a valid [JSON Schema](https://json-schema.org/) document.
The Polyn CLI tool will combine your event schema with the [Cloud Events Schema](https://cloudevents.io/) when it adds it to the Polyn Event Registry.
This means you only need to include the JSON Schema for the `data` portion of the Cloud Event and not the entire Cloud Event schema.

## Schema Versioning

### New Event

A new event schema file should be a lower-case, dot-separated, name with a `v1` suffix

### Existing Event

Existing event schemas can be changed without updating the file name if the change is backwards-compatible.
Backwards-compatibile meaning that any services Producing or Consuming the event will not break or be invalid when the
Polyn Event Registry is updated with the change. There are many ways to make breaking change and so you should be
careful when you do this.

Making a change to an event schema that is not backwards-compatible will require you to create a brand new
json file. The new file should have the same name as your old file, but with the version number increased. Your
Producers will need to continue producing both events until you are sure there are no more consumers using the
old event.

## Terraform State

Terraform generates and maintains a [`terraform.tfstate`](https://www.terraform.io/language/state) file that is used to map terraform configuration to real production server instances. Polyn needs to interact with this file differently based on whether we are developing locally or in a production environment.

### Local Development

For local development Polyn expects the `terraform.tfstate` file to exist in the local file system. However, it should not be checked in to version control. We don't want experiments and updates made on a local developer machines to end up as the "source of truth" for our production infrastucture.

### Production

In production Terraform recommends keeping `terraform.tfstate` in a [remote storage location](https://www.terraform.io/language/state). The remote state file should be the "source of truth" for your infrastucture and shouldn't be getting accessed during development. Depending on the size of your organization and security policies, not all developers will have access to the remote storage source and you don't want that to prohibit them from adding events, streams, or consumers.

Polyn expects you to keep a `./remote_state_config/backend.tf` file that configures a Terraform [backend](https://www.terraform.io/language/settings/backends/configuration). This will only be used when `POLYN_ENV=production`.