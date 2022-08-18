provider "jetstream" {
  servers = var.jetstream_servers
  credentials = var.nats_credentials
}
