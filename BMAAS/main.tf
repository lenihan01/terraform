terraform {
  required_providers {
    hpegl = {
      source  = "HPE/hpegl"
      version = ">= 0.3.12"
    }
  }
}

provider "hpegl" {    
  # metal block for configuring bare metal resources.
  metal {   
  } 
}

data "hpegl_metal_available_images" "ubuntu" { 
  # select anything that looks like ubuntu:20.04
  filter {
    name   = "flavor"
    values = ["(?i)ubuntu"] 
  }

  filter {
    name   = "version"
    values = ["20.04*"] 
  }
}
locals {
  ubuntu_image = format("%s@%s", data.hpegl_metal_available_images.ubuntu.images[0].flavor,
                          data.hpegl_metal_available_images.ubuntu.images[0].version)
}

data "hpegl_metal_available_resources" "available" {
}
locals {
  location = ([for msize in data.hpegl_metal_available_resources.available.machine_sizes : msize.location 
                    if msize.quantity > 0])[0]
}


# choosing machine size/Compute Instance Type to deploy OS.
locals {
  machine_size = ([for msize in data.hpegl_metal_available_resources.available.machine_sizes : msize.name 
                    if msize.location == local.location])
}

resource "hpegl_metal_ssh_key" "newssh_1" {
  name       = "TF_ssh_01"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCv03o//GEQ9/6eI1qZleyBbSndg0n5AkcKVnf5D4fEjwkWrtSIJEnROqJddEAn2XYALAk9x1AcB4Nue3q4tDG17VeK3ODo0+9Dx0LYqUTawnFWmo4X80QKr658Jmt7Enmnk5x2IrUDcNwAzALVellkBbwq7QbYUu1swSycNlNhSfGizqo/lQCNIHXyeRQ8oJxOuZkbiturXHZL389blIrTeUo53xmwE1TolVS8QzZRN8ve1GjFvpC5dl6orzi6LXDcrDcbZaxlrW+YQqyaipFRAw1DyTalrfpqxtq/Y9+Elz5xgCnUaepHN6ha/k81wtI2rySHga6pMOcJKlxaRS5OfzdrWh7oi2tEAaiq2y3pTr9hROQ2OGcMNU5gxbVU2ymeXdHVsAHMCmyKvQe0g0/fJzmNA/excogFCWDN7Spy9s2V39IbEKttyXjD/dpave7re9eFzYHA1CBEnNjMuvJj0H4tnpAETdQ6UbnjbE4JYn5eKGvnJ2w1JTfSdMK8nMcxqo4HfHWuLFuntCV9GAlWIVIvJn1pYisY8kEOtN5w6QrLTfsei96/TfssAsfhrDrVtgcgNU3EvZlC6Uaaly7D0ISFeufsxkPswu+jGNUJvGEqDiqvt05lSEZWS5viR/TOROTlicaGN9dhez/fqHcj5cnuoK1pmibK5GT7/Yf1Gw== user1@quattronetworks.com"
}

resource "hpegl_metal_volume" "iscsi_volume" {
  name        = "tf-iscsi-volume-01"
  size        = 20
  shareable   = true
  flavor      = "Block Storage – Standard (Bs)"
  location    = local.location
  description = "Hello from Terraform"
}

resource "hpegl_metal_network" "newpnet_1" {
  name        = "TF_Net_01"
  description = "Hello from Terraform"
  location    = local.location
  ip_pool {
    name          = "TF_Netpool_01"
    description   = "Hello from Terraform"
    ip_ver        = "IPv4"
    base_ip       = "10.0.0.0"
    netmask       = "/24"
    default_route = "10.0.0.1"
    sources {
      base_ip = "10.0.0.3"
      count   = 10
    }
    dns      = ["10.0.0.50"]
    proxy    = "https://10.0.0.60"
    no_proxy = "10.0.0.5"
    ntp      = ["10.0.0.80"]
  }
}

resource "hpegl_metal_host" "TF_BMhost_01" {
  count = 2
  name             = "TF-BMhost-${count.index}"
  image            = local.ubuntu_image
  machine_size     = local.machine_size[0]
  ssh              = [hpegl_metal_ssh_key.newssh_1.id]
  networks         = ["Primary","Storage-Client",hpegl_metal_network.newpnet_1.name]
  network_route    = hpegl_metal_network.newpnet_1.name
  volume_attachments = [hpegl_metal_volume.iscsi_volume.id]
  location         = local.location
  description      = "Hello from Terraform"
  # Attaching tags 
  labels           = { "purpose" = "Terraform" }
}