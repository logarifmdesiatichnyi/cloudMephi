terraform {
  required_version = ">= 1.0.0"

  required_providers {
    rustack = {
      source = "pilat/rustack"
      version = "1.1.7"
    }
  }
}

provider "rustack" {
  api_endpoint = "https://cloud.mephi.ru"
  token        = ""
}

# Данные проекта
data "rustack_project" "my_project" {
  name = "PostgreSQL"
}

data "rustack_hypervisor" "kvm" {
  project_id = data.rustack_project.my_project.id
  name       = "РУСТЭК"
}

data "rustack_vdc" "vdc" {
  project_id = data.rustack_project.my_project.id
  name       = "PostgreSQL"
}

data "rustack_network" "service_network" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Сеть"
}

data "rustack_storage_profile" "ssd" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "ssd"
}

data "rustack_template" "ubuntu20" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Ubuntu 20.04"
}

data "rustack_firewall_template" "allow_default" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Разрешить исходящие"
}

data "rustack_firewall_template" "allow_ssh" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Разрешить SSH"
}

data "rustack_firewall_template" "allow_postgresql" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "PostgreSQL"
}

# Создание порта для PostgreSQL-1
resource "rustack_port" "vm_port_1" {
  vdc_id           = data.rustack_vdc.vdc.id
  network_id       = data.rustack_network.service_network.id
  firewall_templates = [
    data.rustack_firewall_template.allow_default.id,
    data.rustack_firewall_template.allow_postgresql.id,
    data.rustack_firewall_template.allow_ssh.id,
  ]
}

# Создание порта для PostgreSQL-2
resource "rustack_port" "vm_port_2" {
  vdc_id           = data.rustack_vdc.vdc.id
  network_id       = data.rustack_network.service_network.id
  firewall_templates = [
    data.rustack_firewall_template.allow_default.id,
    data.rustack_firewall_template.allow_postgresql.id,
    data.rustack_firewall_template.allow_ssh.id,
  ]
}

# Виртуальная машина PostgreSQL-1
resource "rustack_vm" "postgresql_1" {
  vdc_id      = data.rustack_vdc.vdc.id
  name        = "PostgreSQL-1"
  cpu         = 4
  ram         = 8
  template_id = data.rustack_template.ubuntu20.id
  user_data   = file("user_data.yaml")

  system_disk {
    size               = 30
    storage_profile_id = data.rustack_storage_profile.ssd.id
  }

  ports    = [rustack_port.vm_port_1.id]
  floating = true
}

# Виртуальная машина PostgreSQL-2
resource "rustack_vm" "postgresql_2" {
  vdc_id      = data.rustack_vdc.vdc.id
  name        = "PostgreSQL-2"
  cpu         = 4
  ram         = 8
  template_id = data.rustack_template.ubuntu20.id
  user_data   = file("user_data.yaml")

  system_disk {
    size               = 30
    storage_profile_id = data.rustack_storage_profile.ssd.id
  }

  ports    = [rustack_port.vm_port_2.id]
  floating = true
}
