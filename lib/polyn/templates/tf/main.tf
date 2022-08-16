terraform {
  required_providers {
    jetstream = {
      source = "nats-io/jetstream"
    }
  }

}

variable "jetstream_servers" {
  type = string
  description = "The JetStream servers to connect to"
}

variable "nats_credentials" {
  type = string
  description = "Path to file with NATS credentials"
}

provider "jetstream" {
  servers = var.jetstream_servers
  credentials = var.nats_credentials
}
