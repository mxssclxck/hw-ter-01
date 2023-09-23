resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tftpl",
    {
      webservers = yandex_compute_instance.web_vm,
      databases  = yandex_compute_instance.web_vm_2,
      storage    = yandex_compute_instance.storage_vm,
    }
  )
  filename = "${abspath(path.module)}/hosts.cfg"
}

resource "local_file" "playbook" {
  content = templatefile("${path.module}/playbook.tftpl",
    {
      ssh_user = var.vms_list.0.ssh_user
    }
  )
  filename = "${abspath(path.module)}/playbook.yaml"
}

resource "null_resource" "web_hosts_provision" {
depends_on = [ yandex_compute_instance.web_vm_2, yandex_compute_instance.storage_vm, local_file.playbook, local_file.hosts_cfg ]
  provisioner "local-exec" {                  
    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg ${abspath(path.module)}/playbook.yaml"
    on_failure = continue
    environment = { ANSIBLE_HOST_KEY_CHECKING = "Flase" }
  }
    triggers = {  
      always_run         = "${timestamp()}" #всегда т.к. дата и время постоянно изменяются
      playbook_src_hash  = file("${abspath(path.module)}/playbook.tftpl") # при изменении содержимого playbook.tftpl файла
      ssh_public_key     = local.ssh_file # при изменении переменной
    }
}
