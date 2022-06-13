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

provider "jetstream" {
  servers = var.jetstream_servers
}
