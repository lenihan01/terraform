# (C) Copyright 2021 Hewlett Packard Enterprise Development LP
variable "instance_name" {
  description = "The name for the instance"
  type        = string
  default     = "perconadb"
}

variable "location" {
  description = "Tenant location"
  type        = string
  default     = "HPE"
}

variable "space" {
  description = "space"
  type        = string
  default     = "Default"
}

variable "cloud" {
  description = "cloud"
  type        = string
  default     = "HPE GreenLake VMaaS Cloud-Trial3"
}

variable "datastore" {
  description = "datastore"
  type        = string
  default     = "gl2-trial3-Vol0"
}

variable "network" {
  description = "network"
  type        = string
  default     = "App-Net"
}


variable "group" {
  description = "group"
  type        = string
  default     = "user-infraxx"
}

variable "resource_pool" {
  description = "resourcepool"
  type        = string
  default     = "ComputeResourcePool"
}

variable "layout" {
  description = "layout"
  type        = string
  #default     = "ubuntulayout"
  default = "Vmware VM"
}

variable "instance_type" {
  description = "instance_type"
  type        = string
  #default     = "ubuntu20"
  default = "vmware"
}

variable "service_plan" {
  description = "serviceplan"
  type        = string
  #default     = "G1-Large"
  default = "G1-Medium"
}


variable "template" {
  description = "template"
  type        = string
  default     = "vanilla-centos7-x86_64-09072020"
}

variable "sst_user" {
  description = "sst username"
  type        = string
}

variable "sst_password" {
  description = "sst password"
  type        = string
}

variable "percona_root_password" {
  description = "percona root password"
  type        = string
}

variable "vm_username" {
  description = "remote host username"
  type        = string
}

variable "vm_password" {
  description = "remote host password"
  type        = string
}

variable"folder" {
  description = "folder"
  type = string
  default = "ComputeFolder"
}

