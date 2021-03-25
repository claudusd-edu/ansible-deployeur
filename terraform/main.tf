variable "ovh_user_name" {}

variable "ovh_password" {}

variable "ovh_project_id" {}

provider "openstack" {
  auth_url = "https://auth.cloud.ovh.net/v3"
  domain_name = "Default"
  user_name = var.ovh_user_name
  password = var.ovh_password
  tenant_id = var.ovh_project_id
  region = "GRA3"
}

terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.33.0"
    }
    local = {
      source = "registry.terraform.io/hashicorp/local"
      version = "2.0.0"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

data "openstack_images_image_v2" "debian" {
  name        = "Debian 10"
  most_recent = true
}

resource "openstack_compute_instance_v2" "yolo" {
    name = "yolo"
    image_id = data.openstack_images_image_v2.debian.id
    flavor_name = "s1-2"
    key_pair = "me"
    region = "GRA3"
}

data "template_file" "inventory" {
  template = file("${path.cwd}/${path.module}/inventory.tpl")
  vars = {
    yolo_ip = openstack_compute_instance_v2.yolo.network[0].fixed_ip_v4
  }
}

resource "local_file" "inventory" {
    content     = data.template_file.inventory.rendered
    filename = "${path.cwd}/${path.module}/inventory"
}
