# (C) Copyright 2021 Hewlett Packard Enterprise Development LP

#  Set-up for terraform >= v0.13
terraform {
  required_providers {
    hpegl = {
      source = "registry.terraform.io/hewlettpackard/hpegl"
      #      version = ">= 0.0.1"
      version = "0.1.0-beta7"
    }
  }
}

provider "hpegl" {
  vmaas {
    location   = var.location
    space_name = var.space
  }
}

data "hpegl_vmaas_cloud" "cloud" {
  name = var.cloud
}

data "hpegl_vmaas_datastore" "c_3par" {
  cloud_id = data.hpegl_vmaas_cloud.cloud.id
  name     = var.datastore
}

data "hpegl_vmaas_network" "network" {
  name = var.network
}


data "hpegl_vmaas_group" "terraform_group" {
  name = var.group
}

data "hpegl_vmaas_resource_pool" "cl_resource_pool" {
  cloud_id = data.hpegl_vmaas_cloud.cloud.id
  name     = var.resource_pool
}


data "hpegl_vmaas_layout" "vmware" {
  name               = var.layout
  instance_type_code = var.instance_type
}

data "hpegl_vmaas_plan" "g1_large" {
  name = var.service_plan
}


data "hpegl_vmaas_template" "vanilla" {
  name = var.template
}

data"hpegl_vmaas_cloud_folder""compute_folder" {
  cloud_id = data.hpegl_vmaas_cloud.cloud.id
  name = var.folder
}

resource "random_integer" "random" {
  min = 1
  max = 50000
}

resource "hpegl_vmaas_instance" "boot_node" {
  name               = "${var.instance_name}-boot-${resource.random_integer.random.result}"
  cloud_id           = data.hpegl_vmaas_cloud.cloud.id
  group_id           = data.hpegl_vmaas_group.terraform_group.id
  layout_id          = data.hpegl_vmaas_layout.vmware.id
  plan_id            = data.hpegl_vmaas_plan.g1_large.id
  instance_type_code = data.hpegl_vmaas_layout.vmware.instance_type_code
  network {
    id = data.hpegl_vmaas_network.network.id
  }
  #environment_code = data.hpegl_vmaas_environment.dev.code
  volume {
    name         = "root_vol"
    size         = 50
    datastore_id = data.hpegl_vmaas_datastore.c_3par.id
    root         = true
  }
  labels = ["DBaaS"]
  tags = {
    Environment = "Development"
  }
  hostname = "${var.instance_name}-${resource.random_integer.random.result}"
  config {
    template_id      = data.hpegl_vmaas_template.vanilla.id
    resource_pool_id = data.hpegl_vmaas_resource_pool.cl_resource_pool.id
    no_agent         = false
    asset_tag        = "vm_tag"
    create_user      = true
    folder_code      = data.hpegl_vmaas_cloud_folder.compute_folder.code
  }
}

resource "hpegl_vmaas_instance" "node1" {
  name               = "${var.instance_name}-node1-${resource.random_integer.random.result}"
  cloud_id           = data.hpegl_vmaas_cloud.cloud.id
  group_id           = data.hpegl_vmaas_group.terraform_group.id
  layout_id          = data.hpegl_vmaas_layout.vmware.id
  plan_id            = data.hpegl_vmaas_plan.g1_large.id
  instance_type_code = data.hpegl_vmaas_layout.vmware.instance_type_code
  network {
    id = data.hpegl_vmaas_network.network.id
  }
  #environment_code = data.hpegl_vmaas_environment.dev.code
  volume {
    name         = "root_vol"
    size         = 50
    datastore_id = data.hpegl_vmaas_datastore.c_3par.id
    root         = true
  }
  labels = ["DBaaS"]
  tags = {
    Environment = "Development"
  }
  hostname = "${var.instance_name}-${resource.random_integer.random.result}"
  config {
    template_id      = data.hpegl_vmaas_template.vanilla.id
    resource_pool_id = data.hpegl_vmaas_resource_pool.cl_resource_pool.id
    no_agent         = false
    asset_tag        = "vm_tag"
    create_user      = true
    folder_code      = data.hpegl_vmaas_cloud_folder.compute_folder.code
  }
}

resource "hpegl_vmaas_instance" "node2" {
  name               = "${var.instance_name}-node2-${resource.random_integer.random.result}"
  cloud_id           = data.hpegl_vmaas_cloud.cloud.id
  group_id           = data.hpegl_vmaas_group.terraform_group.id
  layout_id          = data.hpegl_vmaas_layout.vmware.id
  plan_id            = data.hpegl_vmaas_plan.g1_large.id
  instance_type_code = data.hpegl_vmaas_layout.vmware.instance_type_code
  network {
    id = data.hpegl_vmaas_network.network.id
  }
 # environment_code = data.hpegl_vmaas_environment.dev.code
  volume {
    name         = "root_vol"
    size         = 50
    datastore_id = data.hpegl_vmaas_datastore.c_3par.id
    root         = true
  }
  labels = ["DBaaS"]
  tags = {
    Environment = "Development"
  }
  hostname = "${var.instance_name}-${resource.random_integer.random.result}"
  config {
    template_id      = data.hpegl_vmaas_template.vanilla.id
    resource_pool_id = data.hpegl_vmaas_resource_pool.cl_resource_pool.id
    no_agent         = false
    asset_tag        = "vm_tag"
    create_user      = true
    folder_code      = data.hpegl_vmaas_cloud_folder.compute_folder.code
  }
}

resource "null_resource" "DeployPersona" {
  provisioner "local-exec" {
    command = <<EOT
    # Remove host entry from known_hosts if exists
    ssh-keygen -R ${resource.hpegl_vmaas_instance.boot_node.containers[0].ip}
    ssh-keygen -R ${resource.hpegl_vmaas_instance.node1.containers[0].ip}
    ssh-keygen -R ${resource.hpegl_vmaas_instance.node2.containers[0].ip}
    # Add sleep for the infrastructure to be ready before running the playbook
    sleep 120
    echo "Trigger ansible playbook to bring-up perconaDB boot node"
    ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -e 'SST_USER=${var.sst_user}' -e 'SST_PASSWORD=${var.sst_password}' -e 'BOOT_NODE_IP=${resource.hpegl_vmaas_instance.boot_node.containers[0].ip}' -e 'NODE1_IP=${resource.hpegl_vmaas_instance.node1.containers[0].ip}' -e 'NODE2_IP=${resource.hpegl_vmaas_instance.node2.containers[0].ip}' -e 'ansible_user=${var.vm_username}' -e 'ansible_ssh_pass=${var.vm_password}' -e 'ansible_sudo_pass=${var.vm_password}'  -e 'MYSQL_ROOT_PASSWORD=${var.percona_root_password}' -i '${resource.hpegl_vmaas_instance.boot_node.containers[0].ip},' percona_boot_node.yml
    echo "Trigger ansible playbook to bring-up node1"
    ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -e 'SST_USER=${var.sst_user}' -e 'SST_PASSWORD=${var.sst_password}' -e 'BOOT_NODE_IP=${resource.hpegl_vmaas_instance.boot_node.containers[0].ip}' -e 'NODE1_IP=${resource.hpegl_vmaas_instance.node1.containers[0].ip}' -e 'NODE2_IP=${resource.hpegl_vmaas_instance.node2.containers[0].ip}' -e 'ansible_user=${var.vm_username}' -e 'ansible_ssh_pass=${var.vm_password}' -e 'ansible_sudo_pass=${var.vm_password}'  -e 'MYSQL_ROOT_PASSWORD=${var.percona_root_password}' -i '${resource.hpegl_vmaas_instance.node1.containers[0].ip},' percona_node.yml
    echo "Trigger ansible playbook to bring-up node2"
    ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -e 'SST_USER=${var.sst_user}' -e 'SST_PASSWORD=${var.sst_password}' -e 'BOOT_NODE_IP=${resource.hpegl_vmaas_instance.boot_node.containers[0].ip}' -e 'NODE1_IP=${resource.hpegl_vmaas_instance.node1.containers[0].ip}' -e 'NODE2_IP=${resource.hpegl_vmaas_instance.node2.containers[0].ip}' -e 'ansible_user=${var.vm_username}' -e 'ansible_ssh_pass=${var.vm_password}' -e 'ansible_sudo_pass=${var.vm_password}'  -e 'MYSQL_ROOT_PASSWORD=${var.percona_root_password}' -i '${resource.hpegl_vmaas_instance.node2.containers[0].ip},' percona_node.yml
    EOT
  }
}
