terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.6.0"
    }
  }
}

provider "digitalocean" {}

resource "digitalocean_droplet" "development" {
  region    = "fra1"
  ipv6      = true
  ssh_keys  = [29367970, 22187648, 3688634]
  name      = "development"
  size      = "s-2vcpu-4gb"
  image     = "ubuntu-20-04-x64"

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

    connection {
      type        = "ssh"
      user        = "root"
      timeout     = "2m"
      host        = digitalocean_droplet.development.ipv4_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh initialize",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      timeout     = "2m"
      host        = digitalocean_droplet.development.ipv4_address
    }
  }
}

resource "digitalocean_firewall" "development" {
  name = "ssh-and-http-https-only"
  droplet_ids = [digitalocean_droplet.development.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output "public_ip" {
  value = digitalocean_droplet.development.ipv4_address
}
