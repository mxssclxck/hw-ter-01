output "virtual_machines_info" {
  value = [
    for instance in concat(tolist(yandex_compute_instance.storage_vm), tolist(yandex_compute_instance.web_vm), tolist(values(yandex_compute_instance.web_vm_2))) : {
      name = instance.name
      id   = instance.id
      fqdn = instance.fqdn
    }
  ]
}
