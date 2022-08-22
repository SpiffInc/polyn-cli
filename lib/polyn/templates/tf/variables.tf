variable "jetstream_servers" {
  type = string
  description = "The JetStream servers to connect to"
}

variable "nats_credentials" {
  type = string
  description = "Path to file with NATS credentials"
}

variable "polyn_env" {
  type = string
  description = "The environment terraform is running in"
  default = "development"
}