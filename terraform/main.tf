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

resource "openstack_compute_keypair_v2" "test-keypair" {
  name       = "cloud"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXAdHrf3WY5bidt1ERb3/jS8qupj9QQ3m2Jr8xIgS+lRhCvjx9nevWH8rucccSZ4ztj4d3bocJbjxSMvu4lahKz9QaTl0J+6AYBIIvB/H3QmiL3BbYQ7VG6b4MJPuEYOnp835Ii7m1CFqc0Mn6FNlhg3QsoxBZiu+dhVDBMt3XZIBMnQuCeY0tGzl+Al/P5XCGv6nfJQIl/50Ln+OqFtncEPX8FfFvPt5VGkHRjgHc91Rl46BX/ntqOQpR8mf8oUlb0fXpkwgN8yrCL7e0icP/w/QRIFtDLNsi5o+IkSs3EpE5WRsEEkUyhUb9MMmNndPhRR+/g0vOolH4KlXqXN3BKGVSFUDGXHnD0YAcNCxti8Q/m3j4BihwxJw/mQjSFaEMfn6SzMAspkjgh5GE5aAy+9wV5q9tRGks4ns1rjoqSSVGTTyTU0At4hEryTVKABYMvaKOQjKCb0kVwX0L/3hu6zCAtnoitKP5O6GnaAhfVx9nClWHKtoPZudr2p1vJWW39FQ6bOAOJQOScM1nxxUKN7fr39xpyr0a0vWYzrgrVBL8g/hekn3HqTtwdt7ZkrC+uoCxfEUmsqIZ8M4/dQtwB34RjBpV2m2GPK2dya2SEhHsExrAsaGkLstKAfEHBlx/HNUkVlX0l+7COlW1mRHq228yDOv1kRQyrvtc1okhYQ== claude.dioudonnat@be-ys.cloud"
}

resource "openstack_compute_instance_v2" "yolo" {
    name = "yolo"
    image_id = data.openstack_images_image_v2.debian.id
    flavor_name = "s1-2"
    key_pair = "cloud"
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
