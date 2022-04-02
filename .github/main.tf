# Create test instance on digital ocean in AMS3
terraform {
  required_version = ">= 1.1.0"
  # require vault and digital ocean providers
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.19.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "3.4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.2"
    }
  }
  backend "consul" {
    path = "do/test/ansible-role-consul"
  }
}

data "vault_generic_secret" "do_token" {
  path = "digitalocean/tokens"
}

provider "digitalocean" {
  token = data.vault_generic_secret.do_token.data["terraform"]
}

data "digitalocean_vpc" "vpc" {
  name = "terraform-vpc-hah"
}

data "digitalocean_ssh_key" "test_instances" {
  name = "test-instances"
}

data "vault_generic_secret" "ssh_key" {
  path = "digitalocean/ssh_key"
}

data "digitalocean_image" "base_image" {
  slug = "ubuntu-21-10-x64"
}

resource "digitalocean_droplet" "test" {
  name          = format("ansible-role-do-base-platform-test-instance-%s", formatdate("YYYY-MM-DD-hh-mm-ss", timestamp()))
  image         = data.digitalocean_image.base_image.id
  size          = "s-1vcpu-1gb"
  vpc_uuid      = data.digitalocean_vpc.vpc.id
  region        = "ams3"
  tags          = ["ansible-role", "consul", "test"]
  backups       = false
  monitoring    = false
  droplet_agent = true
  ssh_keys      = [data.digitalocean_ssh_key.test_instances.id]
}

# write the private key for Ansible later
resource "local_sensitive_file" "ssh_priv_key" {
  filename        = "ssh_priv_key"
  content         = data.vault_generic_secret.ssh_key.data["private_key"]
  file_permission = "0400"
}

# Create the inventory for Ansible in a local file, templating the ip address of the test instance


output "droplet_output" {
  value = digitalocean_droplet.test.ipv4_address
}
