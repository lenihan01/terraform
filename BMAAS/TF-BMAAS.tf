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

# query available resources.
data "hpegl_metal_available_resources" "available" {
}

# using one of the available SSH keys.
locals  {
  ssh_keys = data.hpegl_metal_available_resources.available.ssh_keys[0].name
}


# choosing a location that has at least one machine available.
locals {
  location = ([for msize in data.hpegl_metal_available_resources.available.machine_sizes : msize.location 
                    if msize.quantity > 0])[0]
}

# Listing required networks for this location.
locals {
  networks = ([for net in data.hpegl_metal_available_resources.available.networks : net.name 
                  if net.host_use == "Required"  && net.location == local.location])
}

# choosing machine size/Compute Instance Type to deploy OS.
locals {
  machine_size = ([for msize in data.hpegl_metal_available_resources.available.machine_sizes : msize.name 
                    if msize.location == local.location])
}


resource "hpegl_metal_host" "demo_host" {
  name          = "demo-host-1"
  image         = local.ubuntu_image
  machine_size  = local.machine_size[0]
  ssh           = [ local.ssh_keys ]
  networks      = local.networks
  location      = local.location
  description   = "Simple Host Deployment Demo"
}