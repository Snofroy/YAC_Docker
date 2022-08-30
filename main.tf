terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = file(var.ya_account_key)
  cloud_id  = var.ya_cloud_id
  folder_id = var.ya_folder_id
  zone      = var.ya_zone
}

data "yandex_vpc_subnet" "rebrain_subnet" {
  name = "default-ru-central1-a"
}

resource "yandex_compute_instance" "vm_centos" { 
  count           = length(var.ya_quantity_centos)
  name            = "srv-${element(var.ya_quantity_centos, count.index)}"
  hostname        = "srv-${element(var.ya_quantity_centos, count.index)}"
  platform_id = var.ya_platform_id

  resources {
    cores  = 2
    memory = 4
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = var.ya_image_id_centos
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.rebrain_subnet.id
    nat = true
  }

  metadata = {
    ssh-keys = "cloud-user:${file(var.my_ssh_key)}"
  }

  labels = {
    user_email : var.my_email
    task_name : "dev-10" 
  }
}

locals {
  ip_addr_centos = yandex_compute_instance.vm_centos.*.network_interface.0.nat_ip_address
}

resource "local_file" "inventory" {
  content  = templatefile("${path.module}/tamplatefile_vm.tftpl", { 
    names_centos  = var.ya_quantity_centos, 
    address_centos = local.ip_addr_centos,
    })
  filename = "${path.module}/Ansible/inventory.yaml"
}

resource "null_resource" "ansible" {
  depends_on = [local_file.inventory]

  provisioner "local-exec" {
    command = "sleep 180s && ansible-playbook ${path.module}/Ansible/docker.yaml -i ${path.module}/Ansible/inventory.yaml"
  }
}