###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "web_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "VM platform"
}

variable "vms_resources" {
  description = "common configs to VMs"
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    vm_web_resources = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
  }
}

variable "vms_list" {
  description = "common configs to VMs"
  type = list(object({
    vm_name        = string
    vm_hostname    = string
    vm_discription = string
    cpu            = number
    ram            = number
    disk           = number
    disk_type      = string
    core_fraction  = number
    ssh_user       = string
    })
  )
  default = [
    {
      vm_name        = "main"
      vm_hostname    = "main"
      vm_discription = "main"
      cpu            = 2
      ram            = 1
      disk           = 10
      disk_type      = "network-ssd"
      core_fraction  = 5
      ssh_user       = "debian"
    },
    {
      vm_name        = "replica"
      vm_hostname    = "replica"
      vm_discription = "replica"
      cpu            = 4
      ram            = 2
      disk           = 11
      disk_type      = "network-hdd"
      core_fraction  = 5
      ssh_user       = "debian"
    }
  ]
}
